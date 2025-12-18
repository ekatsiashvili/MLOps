provider "aws" {
  region = "us-east-1" 
}
# --- 1. IAM РОЛЬ ДЛЯ LAMBDA ---
resource "aws_iam_role" "lambda_exec_role" {
  name = "mlops_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Підключаємо стандартну політику для логів CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- 2. LAMBDA FUNCTIONS ---

resource "aws_lambda_function" "validate_function" {
  function_name = "mlops_validate_data"
  filename      = "lambda/validate.zip"       # Шлях до твого архіву
  handler       = "validate.lambda_handler"   # Ім'я файлу.ім'я функції
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("lambda/validate.zip") # Щоб оновлювалось при зміні коду
}

resource "aws_lambda_function" "log_metrics_function" {
  function_name = "mlops_log_metrics"
  filename      = "lambda/log_metrics.zip"
  handler       = "log_metrics.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("lambda/log_metrics.zip")
}

# --- 3. IAM РОЛЬ ДЛЯ STEP FUNCTION  ---
resource "aws_iam_role" "step_function_role" {
  name = "mlops_step_function_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
}

# Політика: Step Function 
resource "aws_iam_role_policy" "step_function_invoke_policy" {
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          aws_lambda_function.validate_function.arn,
          aws_lambda_function.log_metrics_function.arn
        ]
      }
    ]
  })
}

# --- 4. STEP FUNCTION ---
resource "aws_sfn_state_machine" "mlops_pipeline" {
  name     = "MLOpsTrainingPipeline"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "A simple MLOps pipeline: Validate -> Train/Log"
    StartAt = "ValidateData"
    States = {
      "ValidateData" = {
        Type     = "Task"
        Resource = aws_lambda_function.validate_function.arn
        Next     = "LogMetrics"
      },
      "LogMetrics" = {
        Type     = "Task"
        Resource = aws_lambda_function.log_metrics_function.arn
        End      = true
      }
    }
  })
}

# --- 5. OUTPUT ---
output "step_function_arn" {
  value = aws_sfn_state_machine.mlops_pipeline.arn
}
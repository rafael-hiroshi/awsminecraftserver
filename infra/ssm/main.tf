resource "aws_ssm_parameter" "cloudwatch_agent_configuration" {
  name      = "AmazonCloudWatch-EC2MinecraftServerCWAgent"
  type      = "String"
  overwrite = true
  value     = file("${path.module}/cloudwatch_agent_configuration.json")
}

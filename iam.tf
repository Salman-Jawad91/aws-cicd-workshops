resource "aws_iam_role" "tf-codepipeline-role" {
  name = "tf-codepipeline-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })

}

data "aws_iam_policy_document" "tf_cicd_pipeline_policies" {
  statement {
    sid = ""

    actions = [
      "codestar-connections:UseConnection"
    ]

    resources = [
      "*",
    ]
    effect = "Allow"
  }
    statement {
    sid = ""

    actions = [
      "cloudwatch:*", "s3:*", "codebuild:*"
    ]

    resources = [
      "*",
    ]
    effect = "Allow"
  }

}

resource "aws_iam_policy" "tf_cicd_pipeline_policy" {
  name   = "tf-cicd-pipeline-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.tf_cicd_pipeline_policies.json
}

resource "aws_iam_policy_attachment" "tf_cicd_pipeline_attachment" {
  roles      = [aws_iam_role.tf-codepipeline-role.name]
  policy_arn = aws_iam_policy.tf_cicd_pipeline_policy.arn
  name = "tf-cicd-pipeline-attachment"
}


resource "aws_iam_role" "tf-codebuild-role" {
  name = "tf-codebuild-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })

}


data "aws_iam_policy_document" "tf_cicd_build_policies" {

    statement {
    sid = ""

    actions = [
      "logs:*", "s3:*", "codebuild:*","iam:*"
    ]

    resources = [
      "*",
    ]
    effect = "Allow"
  }

}

resource "aws_iam_policy" "tf_cicd_build_policy" {
  name   = "tf-cicd-build-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.tf_cicd_build_policies.json
}

resource "aws_iam_policy_attachment" "tf_cicd_build_attachment" {
  roles      = [aws_iam_role.tf-codebuild-role.name]
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  name = "tf-cicd-build-attachment"
}
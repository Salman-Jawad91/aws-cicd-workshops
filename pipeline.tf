resource "aws_codebuild_project" "tf_cicd_plan" {
  name          = "tf-cicd-plan"
  description   = "Plan Stage for terraform"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
        credential = var.docerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec        = file("buildspec/plan-buildspec.yml")
  }

}

resource "aws_codebuild_project" "tf_cicd_apply" {
  name          = "tf-cicd-apply"
  description   = "Apply Stage for terraform"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
        credential = var.docerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec        = file("buildspec/apply-buildspec.yml")
  }

}


resource "aws_codepipeline" "tf_codepipeline" {
  name     = "tf-codepipeline"
  role_arn = aws_iam_role.tf-codepipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf-code"]

      configuration = {
        FullRepositoryId = "Salman-Jawad91/aws-cicd-workshops"
        BranchName = "master"
        ConnectionArn    = var.codestar_connector_credentials
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["tf-code"]
      version          = "1"

      configuration = {
        ProjectName = "tf-cicd-plan"
      }
    }
  }

stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["tf-code"]
      version          = "1"

      configuration = {
        ProjectName = "tf-cicd-plan"
      }
    }
  }

}
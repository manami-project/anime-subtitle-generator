locals {
  job_template_creation_tpl_path = "${path.module}/templates/job_template.tpl"
  job_template_creation_json_path = "job_template.json"
}

resource "local_file" "job_template" {
  content = templatefile(local.job_template_creation_tpl_path, {
    s3_target_bucket_arn = var.s3_bucket_target_uri
    template_name = var.name
  })
  filename = local.job_template_creation_json_path
}

data "external" "endpoint_url" {
  program = ["bash", "${path.module}/scripts/fetch_endpoint.sh"]

  query = {
    region = var.region
  }
}

resource "null_resource" "job_template" {
  depends_on = [
    local_file.job_template,
    data.external.endpoint_url,
  ]

  triggers = {
    endpoint_url = data.external.endpoint_url.result.Url
    region = var.region
    template_name = var.name
    template_json_file_path = local.job_template_creation_json_path
    template_file = sha512(file(local.job_template_creation_tpl_path))
  }

  provisioner "local-exec" {
    command = "aws mediaconvert create-job-template --endpoint-url ${self.triggers.endpoint_url} --region ${self.triggers.region} --name \"${self.triggers.template_name}\" --cli-input-json file://${self.triggers.template_json_file_path}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws mediaconvert delete-job-template --endpoint-url ${self.triggers.endpoint_url} --region ${self.triggers.region} --name \"${self.triggers.template_name}\""
  }
}
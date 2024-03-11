data "template_file" "aws_idc_admin" {
  template = file("${path.module}/aws_idc_admin.yaml.tftpl")
  vars = {}
}

output "cf_template_map" {
  value = {
    "aws_idc_admin.yaml.tftpl"  = replace(data.template_file.aws_idc_admin.rendered, "$$$", "$$")
  }
}

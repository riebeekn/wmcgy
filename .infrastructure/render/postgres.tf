resource "render_postgres" "this" {
  name = "${local.name}-database"
  plan = var.render_postgres_plan
  # can't select disk size for free plan
  disk_size_gb  = var.render_postgres_plan == "free" ? null : var.render_postgres_disk_size
  region        = var.render_region
  version       = "15"

  ip_allow_list = [
    {
      cidr_block  = "0.0.0.0/0",
      description = "everywhere"
    }
  ]
}

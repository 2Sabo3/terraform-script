variable "name" {
    type = string
    default = "grafana"
}
variable "namespace" {
    type = string
    default = "monitoring"
}
variable "chart_version" {
    type = string
    default = "10.1.4"
}
variable "admin_user" {
    type = string
    default = "admin"
}
variable "admin_password" {
    type = string
    default = "admin123"
}

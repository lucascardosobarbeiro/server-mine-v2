terraform {
  backend "gcs" {
    bucket  = "terraform-state-server-mine-463823" # O nome do bucket que acabámos de criar.
    prefix  = "terraform/state"                   # Um "caminho" dentro do bucket para organizar os ficheiros.
  }
}
# Atenção: Este bloco é necessário para que o Terraform saiba onde guardar o estado.
# O bucket deve existir antes de executar o Terraform pela primeira vez.
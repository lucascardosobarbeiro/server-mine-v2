🚀 Visão Geral
Este projeto é um estudo de caso abrangente em Engenharia de Nuvem e DevOps modernos, demonstrando a criação de ponta a ponta de uma plataforma de servidores de jogos Minecraft multi-mundo, que é robusta, segura e totalmente automatizada, utilizando a Google Cloud Platform (GCP).

O objetivo transcende a simples hospedagem de um servidor de jogos; serve como uma peça de portfólio robusta que aplica práticas padrão da indústria. Toda a infraestrutura é gerida como código (IaC), e o ciclo de vida da aplicação é automatizado por um pipeline de CI/CD completo, garantindo que o sistema não apenas funcione, mas que seja resiliente, gerenciável e profissional.

✨ Principais Funcionalidades
Infraestrutura como Código (IaC): 100% do ambiente na nuvem (VPC, Firewall, VM, IAM, Storage) é definido declarativamente com Terraform, garantindo reprodutibilidade, controlo de versão e consistência.

Automação de CI/CD Completa: Uma pipeline de GitHub Actions implementa atualizações na aplicação automaticamente após um git push na branch main, eliminando intervenção manual e o risco de erro humano.

Segurança em Múltiplas Camadas:

Acesso Zero Trust: O acesso administrativo via SSH é feito exclusivamente pelo Identity-Aware Proxy (IAP) do Google, mantendo a porta 22 completamente fechada para a internet.

Isolamento de Rede: Os serviços rodam numa VPC customizada com regras de firewall granulares que expõem apenas o proxy.

Princípio do Menor Privilégio: Uma Conta de Serviço dedicada com o mínimo de permissões IAM necessárias para a operação.

Arquitetura Conteinerizada: Todos os serviços (Proxy Velocity, servidores PaperMC) rodam em contentores Docker isolados, orquestrados na VM pelo Docker Compose.

Resiliência e Operações Profissionais:

Backups Automatizados: Um cron job na VM executa backups diários dos mundos para o Google Cloud Storage.

Proxy & Alta Disponibilidade: O Velocity atua como um ponto de entrada único e seguro, permitindo que os jogadores troquem de servidor sem se desconectar e protegendo os servidores de jogo de acesso direto.

Gestão de Estado Centralizada: O estado do Terraform é gerido por um Backend Remoto no GCS, permitindo trabalho colaborativo e seguro.

🏗️ Arquitetura e Detalhes Técnicos
A plataforma foi projetada com foco em segurança, automação e separação de responsabilidades. Esta arquitetura não apenas fornece um servidor Minecraft funcional, mas também serve como um modelo para implantar aplicações conteinerizadas na GCP seguindo os princípios modernos de DevOps.

Diagrama de Alto Nível
                               +----------------------------------+
[ Git Push ] ------------> |   GitHub Actions (CI/CD)         | ----+
                               +----------------------------------+     | (SSH via IAP)
                                                                        v
+----------+   (Internet)    +-----------------+   +------------------+   +-------------------------------------+
|  Jogador | --------------> |   Firewall GCP  |-->|      IP Estático   |   |        Máquina Virtual (GCE)        |
+----------+                 | (Porta 25565)   |   |                  |   |                                     |
                             +-----------------+   +------------------+   |   +-------------------------------+   |
                                                                        |   |        Docker Engine          |   |
                                                                        |   |                               |   |
                                                                        |   | [ Container Proxy Velocity ]  |   |
                                                                        |   |      ^ (Porta 25565)          |   |
                                                                        |   |      |                        |   |
                                                                        |   | <-----> [Rede Docker] <-------> |   |
                                                                        |   |      |                        |   |
                                                                        |   |      v                        |   |
                                                                        |   | [ Containers Servidores Jogo] |   |
                                                                        |   | (Lobby, Sobrevivência, etc.)  |   |
                                                                        |   +-------------------------------+   |
                                                                        |                                     |
+--------------------------------+                                      +-------------------------------------+
| Google Cloud Storage           | <------------------------------------------ (Backups Agendados via Cron)
| (Bucket para Backups)          |
+--------------------------------+

Análise Detalhada dos Componentes
Terraform (Infraestrutura como Código): Todos os recursos da nuvem são definidos declarativamente. O projeto utiliza um Backend Remoto no GCS para armazenar o ficheiro de estado (.tfstate) de forma segura, permitindo o bloqueio de estado e o trabalho colaborativo entre múltiplas máquinas, resolvendo o problema de estados dessincronizados.

GCP Compute Engine & Debian 11: O workload principal corre numa VM GCE. Após um processo de depuração, o Debian 11 foi escolhido pela sua flexibilidade e suporte robusto a instalações personalizadas, em contraste com as restrições do Container-Optimized OS. O startup-script inclui um processo abrangente para instalar de forma fiável os repositórios oficiais do Docker e o docker-compose.

Docker & Docker Compose: A aplicação é totalmente conteinerizada. Um Proxy Velocity e três servidores PaperMC rodam como serviços isolados. O Docker Compose é usado no script de inicialização para definir e gerir esta aplicação multi-contentor. A configuração ONLINE_MODE: "FALSE" nos servidores de jogo é crítica para permitir que o proxy Velocity lide com a autenticação dos jogadores.

Rede GCP (VPC & IAP): A segurança é primordial.

VPC Customizada: A VM reside numa VPC isolada, com controlo total sobre as sub-redes.

Firewall Granular: As regras de firewall permitem apenas tráfego público na porta 25565 para o jogo e tráfego do serviço IAP da Google para o SSH. A porta 22 não está exposta à internet.

Identity-Aware Proxy (IAP): O acesso administrativo segue um modelo Zero Trust. O IAP autentica cada conexão com base na identidade do utilizador (via IAM), criando um túnel seguro sem a necessidade de uma VPN ou chaves SSH estáticas.

GitHub Actions (CI/CD): As operações de "Dia 2" são automatizadas. Após um processo de depuração detalhado, a pipeline agora utiliza uma Chave de Conta de Serviço (JSON) armazenada de forma segura nos Segredos do GitHub. Este método de autenticação direta provou ser mais robusto para este ambiente do que o Workload Identity Federation. A pipeline usa então o gcloud para se conectar via túnel IAP e executar os comandos de atualização.

Persistência e Backups: Os dados do mundo do Minecraft são persistidos no disco da VM usando volumes Docker. Um cron job executa um script que cria arquivos comprimidos dos dados e os sincroniza para um Bucket no Cloud Storage, que tem o versionamento ativado para segurança extra.

🛠️ Pilha de Tecnologia
Tecnologia

Propósito

Google Cloud Platform

Provedor de Nuvem

Terraform

Infraestrutura como Código

Docker & Docker Compose

Conteinerização & Orquestração

GitHub Actions

CI/CD & Automação

Velocity

Proxy Minecraft

PaperMC

Software do Servidor Minecraft

Bash & Cron

Scripts de Automação & Agendamento

⚙️ Como Começar
Para implantar este projeto, você precisará das seguintes ferramentas instaladas e configuradas.

Pré-requisitos
Uma conta Google Cloud Platform com faturação ativa.

Terraform CLI (v1.0.0+).

Google Cloud SDK (gcloud) autenticado com a sua conta (gcloud auth login).

Um repositório GitHub para hospedar o código do projeto.

Instalação
Clone o Repositório

git clone https://github.com/lucascardosobarbeiro/server-mine-v2.git
cd server-mine-v2

Configure as Variáveis do Terraform
Crie um ficheiro chamado terraform.tfvars copiando o ficheiro de exemplo.

cp terraform.tfvars.example terraform.tfvars

Agora, edite o terraform.tfvars e preencha com os detalhes específicos do seu projeto (ID do Projeto GCP, e-mail, etc.).

Implante a Infraestrutura
Execute os seguintes comandos a partir do diretório raiz do projeto:

# Inicializa os provedores do Terraform e configura o backend remoto
terraform init

# Aplica a configuração para criar a infraestrutura na GCP
terraform apply -auto-approve

Após a conclusão, o Terraform exibirá o IP público do servidor e outros valores importantes.

Configure os Segredos do GitHub

Gere uma Chave de Conta de Serviço (ficheiro JSON) para a conta de serviço sa-minecraft-vm a partir do Console do GCP.

No seu repositório do GitHub, navegue para Settings > Secrets and variables > Actions.

Crie um novo segredo de repositório chamado GCP_SA_KEY e cole todo o conteúdo do ficheiro JSON descarregado como o seu valor.

O projeto está agora totalmente implantado e a pipeline de CI/CD está ativa.

🕹️ Fluxo de Trabalho do Projeto
Dia 1: Provisionamento
O comando terraform apply lida com toda a configuração do "Dia 1". Ele constrói a rede, provisiona a VM e usa um script de inicialização para instalar o Docker, configurar o proxy Velocity e o docker-compose.yml, e iniciar todos os contentores.

Dia 2: Operações e Atualizações
Toda a manutenção subsequente é tratada através do fluxo de trabalho GitOps:

Um desenvolvedor faz uma alteração localmente (ex: atualiza uma configuração do servidor).

A alteração é enviada para a branch main no GitHub.

O push aciona automaticamente o workflow do GitHub Actions.

A pipeline autentica-se na GCP usando a Chave de Conta de Serviço segura.

Ela estabelece uma conexão SSH segura com a VM através do túnel IAP.

Finalmente, executa os comandos docker compose para aplicar as atualizações à aplicação em execução.
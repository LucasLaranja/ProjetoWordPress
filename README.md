# Projeto WordPress com AWS e Docker - PB Compass UOL

![Imagem](/imagens/image.png)

## Descrição

### Instalação e configuração do DOCKER ou CONTAINERD no host EC2;  
### Efetuar Deploy de uma aplicação Wordpress com: container de aplicação RDS database Mysql 
### Configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress 
### Configuração do serviço de Load Balancer AWS para a aplicação Wordpress 
---
## Pontos de atenção

### 1 - Não utilizar ip público para saída do serviços WP (Evitem publicar o serviço WP via IP Público) 
### 2 - Sugestão para o tráfego de internet sair pelo LB (Load Balancer Classic) pastas públicas e estáticos do wordpress sugestão de utilizar o EFS (Elastic File Sistem).
### 3 - Fica a critério de cada integrante usar Dockerfile ou Dockercompose; 
### 4 - Necessário demonstrar a aplicação wordpress funcionando (tela de login).
### 5 - Aplicação Wordpress precisa estar rodando na porta 80 ou 8080;
---

## 1 - Criação do VPC

Primeiro vamos a criação do VPC:

![1](/imagens/1.png)
![2](/imagens/2.png)

* Caso queria economizar, selecione (nenhuma) na opção de Gateways Nat, podem ser configurados depois sem afetar projeto.

![2.5](/imagens/2.5.png)
---
## 2 - Security Groups

Vamos as configurações dos grupos de segurança, começamos criando um grupo para o Load Balancer:

| Type  | Protocol | Port Range | Source Type |  Source   |
| ----- | -------- | ---------- | ----------- | --------- |
| HTTP  |   TCP    |    80      |  Anywhere   | 0.0.0.0/0 |

* Em seguida criamos o grupo para o EC2:

|   Type     | Protocol | Port Range | Source Type |  Source   |
| ---------- |--------- | ---------- | ----------- | --------- |
|    HTTP    |   TCP    |    80      |   Custom    |  LB SG    |

* Logo após partimos para criação do grupo do RDS:

|     Type     | Protocol | Port Range | Source Type |  Source   |
| ------------ | -------- | ---------- | ----------- | --------- |
| MySQL/Aurora |   TCP    |    3306    |   Custom    |   EC2 SG  |

* E por fim o do EFS:

|     Type     | Protocol | Port Range | Source Type |  Source   |
| ------------ | -------- | ---------- | ----------- | --------- |
|      NFS     |   TCP    |    2049    |   Custom    |   EC2 SG  |

* Todas as regras acima são regras de entrada dos respectivos grupos.
---
## 3 - RDS banco de Dados

Vamos a criação do banco de dados:

![3](/imagens/3.png)

* Criar banco de Dados, e siga as configurações:

![4](/imagens/4.png)
![5](/imagens/5.png)
![6](/imagens/6.png)
![7](/imagens/7.png)
![8](/imagens/8.png)

* Adicione o security group do RDS:

![9](/imagens/9.png)

Em Configuração adicional na imagem acima, adicione o nome do banco de dados inicial, isso será usado no seu userdata mais a frente.
---
## 4 - EFS (Sistema de arquivos)

Vamos em criar sistemas de arquivos e depois em personalizar:

![10](/imagens/10.png)
![10.5](/imagens/10.5.png)

* Siga as configurações:

![11](/imagens/11.png)
![12](/imagens/12.png)
![13](/imagens/13.png)

Na imagem acima, selecione subnets privadas e o grupo de segurança da EFS em ambas.
---
## 5 - Target Groups (Grupos de Destino)

Agora vamos para a criação do do target group:

![14](/imagens/14.png)

* Seguindo as configurações:

![15](/imagens/15.png)
![16](/imagens/16.png)
![17](/imagens/17.png)
---

## 6 - Launch Template (EC2)

Partindo agora para a criação do nosso modelo para EC2, na aba de modelos de execução:

![18](/imagens/18.png)

* Clique em criar modelo de execução e siga as configurações:

![19](/imagens/19.png)
![20](/imagens/20.png)
![21](/imagens/21.png)

No meu caso tive que usar tags de recurso, caso você também precise fica ao final da página.

O userdata.sh é colocado em configurações adicionais no final da página, é só adicionar o código:

![22](/imagens/22.png)

Após isso só clicar em criar o modelo de execução.
---
## 7 - Load Balancer

Agora vamos a criação do load balancer, onde vamos ter o url para nossa página:

![23](/imagens/23.png)

* Vamos em criar load balancer:

![24](/imagens/24.png)

* Vamos criar o modelo de application load balancer (primeiro modelo), siga as configurações das imagens:

![25](/imagens/25.png)

* Selecione a sua VPC e aqui também selecione suas subnets públicas, pois é aqui que teremos acesso a rede:
![26](/imagens/26.png)

* Em grupo de segurança selecione o que criamos para o Load Balancer, e em Listeners selecione o target group criado: 

![27](/imagens/27.png)
---
## 8 - Auto Scaling Group

Vamos ao auto scaling group e clique em criar grupo de Auto Scaling:

![28](/imagens/28.png)

* Selecione o modelo de execução criado nos passo anteriores:

![29](/imagens/29.png)

* Próximo passo, selecione o VPC que criamos e selecione Subnets privadas (imagem está como pública, mas é privada não esqueça):

![30](/imagens/30.png)

* Seguindo os passos selecione o target group:

![31](/imagens/31.png)
![32](/imagens/32.png)
![33](/imagens/33.png)

Finalizando o Auto Scaling.
---
## 9 - Resultado

E Assim vamos ao Load balancer e pegamos o DNS, e testando, chegamos ao resultado:

![34](/imagens/34.png)
![35](/imagens/35.png)

Aqui chegamos ao resultado esperado do Projeto.
# Hermes

**O Mensageiro Resiliente de Alta Demanda**

Micro-serviço em Elixir projetado para envio confiável de notificações via e-mail e WhatsApp, capaz de lidar com grandes volumes de tráfego sem sacrificar a confiabilidade.

## Características Principais

- **Tolerante a Falhas**: Implementado com os princípios OTP para recuperação automática de falhas
- **Alta Performance**: Processamento assíncrono e concorrente para lidar com picos de demanda
- **Multi-Canal**: Suporte integrado para e-mail e WhatsApp com interface unificada
- **Escalável**: Arquitetura horizontalmente escalável para crescer com sua aplicação

Construído para ser o mensageiro confiável que sua aplicação precisa, mesmo sob as condições mais desafiadoras.

---

## Pré-requisitos

- Docker
- Docker Compose
- `.env` com as variáveis:
- É possível usar o `.env.example` como base.

```env
# Mailer
SMTP_HOST=diasmd
SMTP_PORT=323
SMTP_USERNAME=admida
SMTP_PASSWORD=dadoiamdai
SMTP_SECURE=false

# AWS SQS
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_REGION=us-east-1
SQS_QUEUE_URL=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/notifications-email
DEFAULT_FROM=noreply@example.com
AWS_SCHEME=http://
AWS_HOST=localstack
AWS_PORT=4566
```

---

## Rodando o Projeto com Docker

1. Subir o LocalStack e o Hermes:

```bash
docker compose up --build
```

2. O LocalStack vai criar automaticamente a fila `notifications-email`.

3. O Hermes vai iniciar e começar a processar mensagens da fila.

---

## Publicando Mensagens de Teste

Para enviar mensagens para o Hermes via SQS:

1. Acesse o container do app:

```bash
docker compose exec localstack sh
```

2. Enviar um e-mail de teste:

```bash
aws --endpoint-url=http://localstack:4566 sqs send-message \
  --queue-url $SQS_QUEUE_URL \
  --message-body '{
    "type": "email",
    "to": "teste@example.com",
    "subject": "Teste Hermes",
    "body": "<h1>Olá!</h1><p>Este é um teste.</p>"
  }'
```

3. Enviar uma mensagem de WhatsApp de teste:

```bash
aws --endpoint-url=http://localstack:4566 sqs send-message \
  --queue-url $SQS_QUEUE_URL \
  --message-body '{
    "type": "whatsapp",
    "to": "+5511999999999",
    "message": "Teste de WhatsApp"
  }'
```

4. Verifique os logs do container `hermes_app` para confirmar que as mensagens foram processadas:

```bash
docker compose logs -f hermes_app
```

---

## Observações

* O Hermes usa **Broadway + SQS** para processamento assíncrono e tolerante a falhas.
* O envio de e-mails utiliza **Swoosh + SMTP**, permitindo fácil troca do provedor.
* Para testes locais, o LocalStack simula o AWS SQS, sem necessidade de credenciais reais.
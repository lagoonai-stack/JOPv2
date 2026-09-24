# Este arquivo de configuração é avaliado pelo Puma. Os métodos de nível superior
# invocados aqui fazem parte da DSL de configuração do Puma. Para mais informações
# sobre os métodos disponíveis na DSL, consulte https://puma.io/puma/Puma/DSL.html.
#
# O Puma inicia um número configurável de processos (workers) e cada processo
# atende cada requisição em uma thread de um pool interno de threads.
#
# É possível controlar o número de workers usando ENV["WEB_CONCURRENCY"]. Defina
# esse valor apenas quando quiser rodar 2 ou mais workers. O padrão já é 1.
# Defina como `auto` para iniciar automaticamente um worker por processador disponível.
#
# O número ideal de threads por worker depende de quanto tempo a aplicação gasta
# aguardando operações de I/O e de quanto se prioriza throughput em relação à latência.
#
# Como regra geral, aumentar o número de threads aumenta o tráfego que um processo
# consegue atender (throughput), mas devido ao Global VM Lock (GVL) do CRuby
# os ganhos diminuem e o tempo de resposta (latência) da aplicação pode piorar.
#
# O padrão é 3 threads, considerado um bom equilíbrio entre throughput e latência
# para a maioria das aplicações Rails.
#
# Bibliotecas que usam connection pool ou outro pool de recursos devem ser configuradas
# para fornecer ao menos tantas conexões quanto o número de threads. Isso inclui
# o parâmetro `pool` do Active Record em `database.yml`.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Define a `porta` na qual o Puma vai escutar para receber requisições; padrão é 3000.
port ENV.fetch("PORT", 3000)

# Permite que o Puma seja reiniciado pelo comando `bin/rails restart`.
plugin :tmp_restart

# Executa o supervisor do Solid Queue dentro do Puma para deploys em servidor único.

# Define o arquivo PID. Padrão: tmp/pids/server.pid em desenvolvimento.
# Em outros ambientes, define o arquivo PID apenas se solicitado.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

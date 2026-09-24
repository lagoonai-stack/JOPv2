# Reinicie o servidor após modificar este arquivo.
#
# Configura parâmetros para filtragem parcial nos logs (ex: "passw" filtra "password").
# Use isto para evitar exposição de informações sensíveis nos logs.
# Veja a documentação de ActiveSupport::ParameterFilter para notações e comportamentos suportados.
Rails.application.config.filter_parameters += %i[
  passw email secret token _key crypt salt certificate otp ssn cvv cvc
]

class ClientDecorator
  def initialize(client)
    @client = client
  end

  def formatted_cpf
    @client.cpf.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
  end

  def full_address
    "#{@client.address}, #{@client.city}, #{@client.state}, #{@client.cep}"
  end

  def google_maps_url
    encoded_address = full_address.gsub(" ", "+")
    "https://maps.google.com/?q=#{encoded_address}"
  end

  def phone_link
    clean_phone = @client.phone.gsub(/\D/, "")
    "tel:#{clean_phone}"
  end

  def whatsapp_link
    clean_phone = @client.phone.gsub(/\D/, "")
    "https://wa.me/#{clean_phone}"
  end

  # Delega todos os outros métodos para o objeto client original
  def method_missing(method_name, *args, &block)
    @client.send(method_name, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    @client.respond_to?(method_name, include_private) || super
  end
end

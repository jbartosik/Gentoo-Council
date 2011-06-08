CustomConfig = {}
for conf in ['bot', 'reminders', 'council_term']
  CustomConfig[conf.camelize] = YAML.load open("config/#{conf}.yml").read
end

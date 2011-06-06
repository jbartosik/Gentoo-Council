CustomConfig = {}
for conf in ['bot', 'reminders']
  CustomConfig[conf.camelize] = YAML.load open("config/#{conf}.yml").read
end

CustomConfig = {}
for conf in ['bot', 'reminders', 'council_term', 'doodle']
  CustomConfig[conf.camelize] = YAML.load open("config/#{conf}.yml").read
end

--{ event handler, config file }
subscribers = {
  input = {
    'event.input.json'
  },
  request = {
    {'event.request.file', 'requests.root'}
  },
  output = {
    'event.output.json'
  },
  log = {
    'event.log.console'
  }
}

def incidents(subset)
  require 'mediawiki_api'
  client = MediawikiApi::Client.new 'https://wikitech.wikimedia.org/w/api.php'
  response = client.action :query,
                           format: 'json',
                           list: 'allpages',
                           apprefix: "Incident documentation/#{subset}",
                           aplimit: '100'
  response.data['allpages'].map { |element| element['title'] }
end
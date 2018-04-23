# frozen_string_literal: true

# Add custom RSS here
atom_feed('xmlns' => 'http://www.w3.org/2005/Atom',
          'xmlns:openSearch' => 'http://a9.com/-/spec/opensearch/1.1/',
          'xmlns:media' => 'http://search.yahoo.com/mrss/') do |feed|
  feed.title('Enter Title Here')
  feed.subtitle('Enter Subtitle here')

  feed.author do |author|
    author.name('Namey McNameson')
    author.email('name@email.com')
  end
end

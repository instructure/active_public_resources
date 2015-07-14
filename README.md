# Active Public Resources

[![Build Status](https://travis-ci.org/instructure/active_public_resources.png)](https://travis-ci.org/instructure/active_public_resources)
[![Code Climate](https://codeclimate.com/github/instructure/active_public_resources.png)](https://codeclimate.com/github/instructure/active_public_resources)
[![Gemnasium](https://gemnasium.com/instructure/active_public_resources.png)](https://gemnasium.com/instructure/active_public_resources)
[![Gem Version](https://badge.fury.io/rb/active_public_resources.png)](http://badge.fury.io/rb/active_public_resources)

Active Public Resources is a collection of resources online which return embeddable or linkable
resources. This gem normalizes the requests and responses into response type objects.

For example, you can search for videos via YouTube, Vimeo and SchoolTube. Each of these
requests will use a common interface (RequestCriteria) and a common response (DriverResponse).

## Installation

Add this line to your application's Gemfile:

    gem 'active_public_resources'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_public_resources

## Concepts

There are several components that make up the full request/response circle with this gem:

* **Request Criteria** - The object which contains the criteria that is passed to the driver to make the request.
* **Driver Response** - The response object which contains the request criteria, next request criteria and a list of resulting response type objects.
* **Response Types** - Objects which are returned in the driver response. Includes Exercise, Folder, Image, Quiz and Video.
* **Return Types** - The linkable, downloadable or embeddable results of the response type.

## Request Criteria

A request criteria in this context is a ruby object which contains the criteria that is to be
passed to the driver.

| Name           | Required? | Description
| -------------- |:---------:| -----------
| query          |     No    | Search term
| channel        |     No    | Id for channel (currently only supported by the youtube driver)
| page           |     No    | Page of results. Defaults to 0
| per_page       |     No    | Items to return per page. Defaults to 25
| content_filter |     No    | Filter flag. Can either be `none` or `strict`. Defaults to `none`
| sort           |     No    | Sort filter. Can be `relevance`, `recent` or `popular`. Defaults to `relevance`
| folder         |     No    | Current folder. This is used for folder-based requests (e.g. Khan Academy). Defaults to `root`

Examples:

```ruby
# Search-based criteria
criteria = APR::RequestCriteria.new(
  :query          => "education",
  :page           => 3,
  :per_page       => 15,
  :sort           => APR::RequestCriteria::SORT_RELEVANCE,
  :content_filter => APR::RequestCriteria::CONTENT_FILTER_NONE
)

# Folder-based criteria
criteria = APR::RequestCriteria.new(
  :folder => "engineering"
)
```

## Driver Response (and Response Types)

A driver response is the object which encapsulates the results of the driver's `perform_request` method. It contains the following data:

* **items**         - Array of Response Types
* **criteria**      - Original search criteria which was used to perform the request
* **next_criteria** - Next criteria which can be used to get the next set of results (e.g. page 2)
* **total_items**   - Total number of results for search criteria

### Folder

A folder is returned from API's which are browsable (e.g. Khan Academy).

* **id**          - ID of folder
* **title**       - Folder name
* **description** - Folder description
* **parent_id**   - ID of parent folder (or `nil` for root)
* **items**       - Array of Response Types for this folder (can include folders as well)

### Image

* **id**          - ID of image
* **title**       - Image name
* **description** - Image description
* **url**         - Image URL (used in HREF)
* **width**       - Image width
* **height**      - Image height

### Quiz

* **id**           - ID of quiz
* **title**        - Quiz name
* **description**  - Quiz description
* **url**          - URL of quiz
* **term_count**   - Number of items in quiz
* **created_date** - Date quiz was created
* **has_images**   - Boolean flag to indicate if quiz has images
* **subjects**     - Array of tags

### Video

* **id**            - ID of video
* **title**         - Video name
* **description**   - Video description
* **thumbnail_url** - Thumbnail image url
* **url**           - URL to video
* **duration**      - Duration in seconds
* **width**         - Video width
* **height**        - Video height
* **username**      - Username of creator
* **num_views**     - Number of views
* **num_likes**     - Number of likes
* **num_comments**  - Number of comments
* **created_date**  - Date created

### Exercise

* **id**            - ID of exercise
* **title**         - Exercise name
* **description**   - Exercise description
* **thumbnail_url** - Thumbnail image url
* **url**           - URL to exercise

## Return Types

Return types are the embeddable, linkable or downloadable parts of the response type.
For example, if you have a video response type, you can either embed the video (oembed),
embed the video (iframe) or link to the video (url).

### File

* **driver**       - name of driver used (e.g. vimeo, youtube, quizlet, etc.)
* **remote_id**    - id of media provided by the driver
* **url**          - this is a URL to the file that can be retrieved without requiring any additional authentication (no sessions, cookies, etc.)
* **text**         - the filename
* **content_type** - content or MIME type of the file to be retrieved

### IFrame

* **driver**    - name of driver used (e.g. vimeo, youtube, quizlet, etc.)
* **remote_id** - id of media provided by the driver
* **url**       - this is used as the 'src' attribute of the embedded iframe
* **title**     - this is used as the 'title' attribute of the embedded iframe
* **width**     - this is used as the 'width' style of the embedded iframe
* **height**    - this is used as the 'height' style of the embedded iframe

### Image URL

* **driver**    - name of driver used (e.g. vimeo, youtube, quizlet, etc.)
* **remote_id** - id of media provided by the driver
* **url**       - this is used as the 'src' attribute of the embedded image tag
* **text**      - this is used as the 'alt' attribute of the embedded image tag
* **width**     - this is used as the 'width' style of the embedded image tag
* **height**    - this is used as the 'height' style of the embedded image tag

### OEmbed

* **driver**    - name of driver used (e.g. vimeo, youtube, quizlet, etc.)
* **remote_id** - id of media provided by the driver
* **url**       - this is the oEmbed resource URL
* **endpoint**  - this is the oEmbed API endpoint URL

### URL

* **driver**    - name of driver used (e.g. vimeo, youtube, quizlet, etc.)
* **remote_id** - id of media provided by the driver
* **url**       - The url. Likely used as the 'href' attribute of the inserted link
* **text**      - this is the suggested text for the inserted link. If the user has already selected
                  some content before opening this dialog, the link will wrap that content and this
                  value may be ignored
* **title**     - this is used as the 'title' attribute of the inserted link
* **target**    - this is used as the 'target' attribute of the inserted link

## Drivers

A driver in this context is a ruby class which performs requests and returns a response.

### Vimeo

To use the Vimeo API, you must have credentials already. This requires a Vimeo app to
be registered. You can do it at [https://developer.vimeo.com/apps](https://developer.vimeo.com/apps).
There are 4 params which are necessary to perform the requests:

| Name                | Required? | Description
| ------------------- |:---------:| -------------
| consumer_key        |    Yes    | Vimeo API Client ID
| consumer_secret     |    Yes    | Vimeo API Client Secret
| access_token        |    Yes    | Vimeo API OAuth Access Token
| access_token_secret |    Yes    | Vimeo API OAuth Access Token Secret

#### Return Types

Vimeo returns **Iframe** and **URL** return types.

#### Example:

```ruby
criteria = APR::RequestCriteria.new( query: "education" )

vimeo = APR::Drivers::Vimeo.new(
  :consumer_key        => 'VIMEO_CONSUMER_KEY',
  :consumer_secret     => 'VIMEO_CONSUMER_SECRET',
  :access_token        => 'VIMEO_ACCESS_TOKEN',
  :access_token_secret => 'VIMEO_ACCESS_TOKEN_SECRET'
)

results = vimeo.perform_request( criteria )
results.items.length          # => 25
results.total_items           # => 145063
results.next_criteria         # => #<ActivePublicResources::RequestCriteria:0x007fa48392d388 @query="education", @page=2, @per_page=25>
results.items.first.title     # => "Kynect 'education'"

more_results = vimeo.perform_request( results.next_criteria )
# ...
```

### YouTube

There are no credentials needed to query YouTube.

#### Return Types

YouTube returns **Iframe** and **URL** return types.

#### Example:

```ruby
criteria = APR::RequestCriteria.new( query: "education" )

youtube = APR::Drivers::Youtube.new

results = youtube.perform_request( criteria )
results.items.length          # => 25
results.total_items           # => 1000000
results.next_criteria         # => #<ActivePublicResources::RequestCriteria:0x007fa48392d388 @query="education", @page=2, @per_page=25>
results.items.first.title     # => "Why I Hate School But Love Education||Spoken Word"

more_results = youtube.perform_request( results.next_criteria )
# ...
```

### SchoolTube

There are no credentials needed to query SchoolTube.

#### Return Types

SchoolTube returns **Iframe** and **URL** return types.

#### Example:

```ruby
criteria = APR::RequestCriteria.new( query: "education" )

schooltube = APR::Drivers::Schooltube.new

results = schooltube.perform_request( criteria )
results.items.length          # => 25
results.total_items           # => nil (API does not offer total items)
results.next_criteria         # => #<ActivePublicResources::RequestCriteria:0x007fa48392d388 @query="education", @page=2, @per_page=25>
results.items.first.title     # => "Fun - Educational School Trips - Call American Tours & Travel"

more_results = schooltube.perform_request( results.next_criteria )
# ...
```

### Quizlet

Quizlet requires and Client ID to perform API requests. You can get this by visiting
[https://quizlet.com/api-dashboard](https://quizlet.com/api-dashboard).

| Name      | Required? | Description
| --------- |:---------:| -------------
| client_id |    Yes    | Quizlet Client ID (used for public and user access)

#### Return Types

Quizlet returns **Iframe** and **URL** return types.

#### Example:

```ruby
criteria = APR::RequestCriteria.new( query: "education" )

quizlet = APR::Drivers::Quizlet.new(
  :client_id => 'rTHYaHnXTz'
)

results = quizlet.perform_request( criteria )
results.items.length          # => 25
results.total_items           # => 5001
results.next_criteria         # => #<ActivePublicResources::RequestCriteria:0x007fa48392d388 @query="education", @page=2, @per_page=25>
results.items.first.title     # => "Education"

results.items.first.return_types.map(&:url)
# => [ "http://quizlet.com/8572574/education-flash-cards/",
       "https://quizlet.com/8572574/flashcards/embedv2",
       "https://quizlet.com/8572574/learn/embedv2",
       "https://quizlet.com/8572574/scatter/embedv2",
       "https://quizlet.com/8572574/speller/embedv2",
       "https://quizlet.com/8572574/test/embedv2",
       "https://quizlet.com/8572574/spacerace/embedv2" ]

more_results = quizlet.perform_request( results.next_criteria )
...
```

## Testing

Tests can be run with the rake task `spec`

    $ rake spec

If you would like to test actual live API's you can do so as well. You need to
create the file `active_public_resources_config.yml` and populate it with actual
credentials for the different services. Once that is done, run the following
command:

    $ rspec --tag live_api

This will run much slower because it is hitting the live API's, but a pass on these
tests means everything is working great!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

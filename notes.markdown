

[Notes](https://www.dropbox.com/s/8t90xxg9yuk26l1/Turing%20-%20Introduction%20to%20Background%20Workers%20%28Notes%29.pages?dl=0)


# Background Workers

Background workers are a process that run in the background so you don't see it. It executes some code in an endless loop. We use them to execute something asynchronously.

`rails g job generate_quotes`
Go to `quotes_controller` and copy `Quote.generate` and past it in the job ...

```
class GenerateQuotesJob < ActiveJob::Base
  queue_as :default

  def perform
    Quote.generate
  end
end
```

In the quotes controller, substitue the quote for the job ..
```
class QuotesController < ApplicationController
  def index
    @quotes = Quote.all
  end

  def create
    GenerateQuotesJob.perform_later

    redirect_to :back, success: 'The quotes were generated successfully.'
  end
end
```

setup active job, the gem 'sidekick', and redis ...
`gem 'sidekiq'` This gem will be used to process all the background workers.

in `application.rb` make sure `config.active_job.queue_adapter = :sidekiq`

in `routes.rb`
add `mount Sidekiq::Web, at: '/sidekiq'`
and `requrie 'sidekiq/web'`
so...
```
requrie 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  root 'site#show'

  resources :books,  only: [:index, :create]
  resources :quotes, only: [:index, :create]
end
```

then install sinatra:
`gem 'sinatra'`
and `bundle`
and restart the server

and go to http://localhost:3000/sidekiq
open a new console tab and `bundle exec sidekiq`

### Now create a job for books

`rails g job generate_books`
```
class GenerateBooksJob < ActiveJob::Base
  queue_as :default

  def perform
    Book.generate
  end
end
```
```
class BooksController < ApplicationController
  def index
    @books = Book.all
  end

  def create
    GenerateBooksJob.perform_later

    redirect_to :back, success: 'The books were generated successfully.'
  end
end
```

### Add an intermediate method:
`GenerateQuotesJob.set(wait: 1.minute)perform_later`

http://edgeguides.rubyonrails.org/active_job_basics.html

# Forman

Currently we need 3 different console tabs open:
 - app
 - rails s
 - redis
 - sidekiq

`gem 'foreman'`, stop server and `bundle`

`touch Procfile` at the root of your application

This file is similar to YAML syntax.
To automatically start our server, add to `Procfile`...
```
web: bundle exec rails s
workers: bundle exec sidekiq
```

When I do `foreman start`, I see two different colors for my two different things running (rails s and sidekiq) ...
```
10:46:25 web.1     | started with pid 59824
10:46:25 workers.1 | started with pid 59825
10:46:28 web.1     | [2015-09-29 10:46:28] INFO  WEBrick 1.3.1
10:46:28 web.1     | [2015-09-29 10:46:28] INFO  ruby 2.2.1 (2015-02-26) [x86_64-darwin14]
10:46:28 web.1     | [2015-09-29 10:46:28] INFO  WEBrick::HTTPServer#start: pid=59824 port=3000
10:46:28 workers.1 | 2015-09-29T16:46:28.315Z 59825 TID-ox6r7etxc INFO: Running in ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-darwin14]
10:46:28 workers.1 | 2015-09-29T16:46:28.315Z 59825 TID-ox6r7etxc INFO: See LICENSE and the LGPL-3.0 for licensing details.
10:46:28 workers.1 | 2015-09-29T16:46:28.315Z 59825 TID-ox6r7etxc INFO: Upgrade to Sidekiq Pro for more features and support: http://sidekiq.org
10:46:28 workers.1 | 2015-09-29T16:46:28.315Z 59825 TID-ox6r7etxc INFO: Booting Sidekiq 3.5.0 with redis options {:url=>nil}
10:46:28 workers.1 | 2015-09-29T16:46:28.316Z 59825 TID-ox6r7etxc INFO: Starting processing, hit Ctrl-C to stop
```

# Recap

We created a background working using ActiveJob
We used it with Sidekiq but we can install ay other thing like 'delayed job' or 'rescue'. We used
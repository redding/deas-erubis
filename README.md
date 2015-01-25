# Deas::Erubis

[Deas](https://github.com/redding/deas) template engine for rendering [Erubis](http://www.kuwata-lab.com/erubis/) templates

## Usage

Register the engine:

```ruby
require 'deas'
require 'deas-erubis'

Deas.configure do |c|

  c.template_source "/path/to/templates" do |s|
    s.engine 'erb', Deas::Erubis::TemplateEngine
  end

end
```

Add `.erb` to any template files in your template source path.  Deas will evaluate their content using Erubis when they are rendered.

### Partials

Deas::Erubis provides template helpers for rendering partial templates.

```erb
# in /path/to/templates/list.html.erb
<h1><%= list.title %></h1>
<ul>
  <% list.items.each do |item| %>
    <%= partial '_list_item.html', :item => item %>
  <% end %>
</ul>

# in /path/to/templates/_list_item.html.erb
<li><%= item.name %></li>

# output
<h1>My List</h1>
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
  <li>Item 3</li>
</ul>
```

There are also helpers for rendering partials that yield to given content blocks (called "capture partials")

```erb
# in /path/to/templates/list.html.erb
<h1><%= list.title %></h1>
<ul>
  <% list.items.each do |item| %>
    <% capture_partial '_list_item.html' do %>
      <span><%= item.name %></span>
    <% end %>
  <% end %>
</ul>

# in /path/to/templates/_list_item.html.erb
<li><%= yield %></li>

# output
# output
<h1>My List</h1>
<ul>
  <li>
    <span>Item 1</span>
  </li>
  <li>
    <span>Item 2</span>
  </li>
  <li>
    <span>Item 3</span>
  </li>
</ul>
```

### Notes

The engine doesn't allow overriding the template scope but instead allows you to pass in data that binds to the template scope as local methods.  By default, the view handler will be bound to the scope via the `view` method in templates.  If you want to change this, provide a `'handler_local'` option when registering:

```ruby
c.template_source "/path/to/templates" do |s|
  s.engine 'erb', Deas::Erubis::TemplateEngine, 'handler_local' => 'view_handler'
end
```

By default, `::Erubis::Eruby` is used to evaluate the templates.  However, Erubis provides "enhancers" that add certain features.  You can pass in any custom eruby class (with any enhancers you like) useing the `'eruby'` option when registering:

```ruby
  c.template_source "/path/to/templates" do |s|
    s.engine 'erb', Deas::Erubis::TemplateEngine, 'eruby' => MyEnhancedEruby
  end
```

The engine doesn't cache templates by default - it opens the file from disk on each render.  To enable caching (which stores the file contents in memory on first use), pass a `'cache'` option when registering:

```ruby
  c.template_source "/path/to/templates" do |s|
    s.engine 'erb', Deas::Erubis::TemplateEngine, 'cache' => true
  end
```

If you wish to provide custom template helpers, organize them in module(s) and pass them with the `'helpers'` option when registering:

```ruby
  c.template_source "/path/to/templates" do |s|
    s.engine 'erb', Deas::Erubis::TemplateEngine, 'helpers' => [MyAwesomeHelpers, NotSoAwesomeHelpers]
  end
```

## Installation

Add this line to your application's Gemfile:

    gem 'deas-erubis'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deas-erubis

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

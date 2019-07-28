### Setup Project
1. We're using `--api` for API application and `-T` for exclude Minitest the default testing framework    
    ```
    $ rails new todos-api --api -T
    ```

### Dependencies
- [rspec-rails](https://github.com/rspec/rspec-rails) - Rails Testing Framework.
- [factory_bot_rails](https://github.com/thoughtbot/factory_bot_rails) - is a fixtures replacement with a straightforward definition syntax, support for multiple build strategies (saved instances, unsaved instances, attribute hashes, and stubbed objects), and support for multiple factories for the same class (user, admin_user, and so on), including factory inheritance.
- [shoulda_matchers](https://github.com/thoughtbot/shoulda-matchers) - Shoulda Matchers provides RSpec- and Minitest-compatible one-liners to test common Rails functionality that, if written by hand, would be much longer, more complex, and error-prone.
- [database_cleaner](https://github.com/DatabaseCleaner/database_cleaner) - It literally cleans our test database to ensure a clean state in each test suite.
- [faker](https://github.com/stympy/faker) - A library for generating fake data. We'll use this to generate test data.

2. Update Gemfile with Adding `rspec-rails` to the `:development` and `:test` groups.
    ```ruby
    group :development, :test do
        gem 'rspec-rails', '~> 3.5'
    end
    ```

3. Update Gemfile with Adding `factory_bot_rails`, `shoulda_matchers`, `faker` and `database_cleaner` only to the `:test` group.
    ```ruby
    group :test do
        gem 'factory_bot_rails', '~> 4.0'
        gem 'shoulda-matchers', '~> 3.1'
        gem 'faker'
        gem 'database_cleaner'
    end
    ```

4. Now install all Gems by running:
    ``` 
    $ bundle install
    ```

5. Initialize the `spec` directory where the tests will reside. (look at step 1, we using `-T` to ignore spec directory generate, now we create the location manually)
    ```
    $ rails generate rspec:install
    ```
    
    the result should be:
    ```diff
    create .rspec
    create  spec
    create  spec/spec_helper.rb
    create  spec/rails_helper.rb
    ```

6. Create a factories directory (factory bot uses this as the default directory). This is where we'll define the model factories.
    ```
    $ mkdir spec/factories
    ```

### Configuration
7. Update file `spec/rails_helper.rb`
    ```ruby
    # require database cleaner at the top level
    require 'database_cleaner'

    # [...]
    # configure shoulda matchers to use rspec as the test framework and full matcher libraries for rails
    Shoulda::Matchers.configure do |config|
        config.integrate do |with|
            with.test_framework :rspec
            with.library :rails
        end
    end

    # [...]
    RSpec.configure do |config|
        # [...]
        # add `FactoryBot` methods
        config.include FactoryBot::Syntax::Methods

        # start by truncating all the tables but then use the faster transaction strategy the rest of the time.
        config.before(:suite) do
            DatabaseCleaner.clean_with(:truncation)
            DatabaseCleaner.strategy = :transaction
        end

        # start the transaction strategy as examples are run
        config.around(:each) do |example|
            DatabaseCleaner.cleaning do
                example.run
            end
        end
        # [...]
    end
    ```

8. Create `Todo` Model
    ```
    $ rails g model Todo title:string created_by:string
    ```

    the result should be :
    ```
    invoke  active_record
    create  db/migrate/20190728034317_create_todos.rb
    create  app/models/todo.rb
    invoke  rspec
    create  spec/models/todo_spec.rb
    ```

9. Now we create `Item` model which references to `Todo` Model. It means 
    ```
    $ rails g model Item name:string done:boolean todo:references
    ```

    the result should be :
    ```
    invoke active_record
    create  db/migrate/20190728035050_create_items.rb
    create  app/models/item.rb
    invoke  rspec
    create  spec/models/item_spec.rb
    ```

10. Then we run the migrations.
    ```
    $ rails db:migrate
    ```

11. final
12. final




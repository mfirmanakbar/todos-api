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

11. Change the rspec file for Todo model. Open `spec/models/todo_spec.rb`
    ```ruby
    require 'rails_helper'

    RSpec.describe Todo, type: :model do
        # Association test
        # ensure Todo model has a 1:m relationship with the Item model
        it { should have_many(:items).dependent(:destroy) }
        # Validation tests
        # ensure columns title and created_by are present before saving
        it { should validate_presence_of(:title) }
        it { should validate_presence_of(:created_by) }
    end
    ```

12. Change the rspec file for Item model. Open `spec/models/item_spec.rb`
    ```ruby
    require 'rails_helper'

    RSpec.describe Item, type: :model do
        # Association test
        # ensure an item record belongs to a single todo record
        it { should belong_to(:todo) }
        # Validation test
        # ensure column name is present before saving
        it { should validate_presence_of(:name) }
    end
    ```

13. Set validation for Todo model Open `app/models/todo.rb`
    ```ruby
    class Todo < ApplicationRecord
        # model association
        has_many :items, dependent: :destroy

        # validations
        validates_presence_of :title, :created_by
    end
    ```

14. Set validation for Item model Open `app/models/item.rb`
    ```ruby
    class Item < ApplicationRecord
        # model association
        belongs_to :todo

        # validation
        validates_presence_of :name
    end
    ```

15. Then test it with command :
    ```
    $ bundle exec rspec 
    ```

    the result should be :
    ```diff
    .....
    Finished in 0.24365 seconds (files took 2.05 seconds to load)
    5 examples, 0 failures
    ```

    if want to spesific files can run command:
    ```
    $ bundle exec rspec spec/models/todo_spec.rb 
    $ bundle exec rspec spec/models/item_spec.rb 
    ```
### Controller
16. Create the Controller
    ```
    $ rails g controller Todos
    $ rails g controller Items
    ```

    the results :
    ```
    create  app/controllers/todos_controller.rb
    invoke  rspec
    create    spec/controllers/todos_controller_spec.rb
    ```
    ```
    create  app/controllers/items_controller.rb
    invoke  rspec
    create    spec/controllers/items_controller_spec.rb
    ```

### Requests Directory
18. Add a requests folder to the spec directory with the corresponding spec files.
    ```
    $ mkdir spec/requests && touch spec/requests/{todos_spec.rb,items_spec.rb} 
    ```

### Test the Data First
19. Add the factory files:
    ```
    $ touch spec/factories/{todos.rb,items.rb}
    ```

20. Define the factories.
    ```ruby
    # spec/factories/todos.rb
    FactoryBot.define do
        factory :todo do
            title { Faker::Lorem.word }
            created_by { Faker::Number.number(10) }
        end
    end
    ```
    ```ruby
    # spec/factories/items.rb
    FactoryBot.define do
        factory :item do
            name { Faker::StarWars.character }
            done false
            todo_id nil
        end
    end
    ```

### Spec fo API Todo
21. Define Todo API Spec `spec/requests/todos_spec.rb`
    ```ruby
    require 'rails_helper'

    # rubocop:disable Metrics/BlockLength
    RSpec.describe 'Todos API', type: :request do
    # initialize test data
    let!(:todos) { create_list(:todo, 10) }
    let(:todo_id) { todos.first.id }

    # Test suite for GET /todos
    describe 'GET /todos' do
        # make HTTP get request before each example
        before { get '/todos' }

        it 'returns todos' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
        end

        it 'returns status code 200' do
        expect(response).to have_http_status(200)
        end
    end

    # Test suite for GET /todos/:id
    describe 'GET /todos/:id' do
        before { get "/todos/#{todo_id}" }

        context 'when the record exists' do
        it 'returns the todo' do
            expect(json).not_to be_empty
            expect(json['id']).to eq(todo_id)
        end

        it 'returns status code 200' do
            expect(response).to have_http_status(200)
        end
        end

        context 'when the record does not exist' do
        let(:todo_id) { 100 }

        it 'returns status code 404' do
            expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
            expect(response.body).to match(/Couldn't find Todo/)
        end
        end
    end

    # Test suite for POST /todos
    describe 'POST /todos' do
        # valid payload
        let(:valid_attributes) { { title: 'Learn Elm', created_by: '1' } }

        context 'when the request is valid' do
        before { post '/todos', params: valid_attributes }

        it 'creates a todo' do
            expect(json['title']).to eq('Learn Elm')
        end

        it 'returns status code 201' do
            expect(response).to have_http_status(201)
        end
        end

        context 'when the request is invalid' do
        before { post '/todos', params: { title: 'Foobar' } }

        it 'returns status code 422' do
            expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
            expect(response.body)
            .to match(/Validation failed: Created by can't be blank/)
        end
        end
    end

    # Test suite for PUT /todos/:id
    describe 'PUT /todos/:id' do
        let(:valid_attributes) { { title: 'Shopping' } }

        context 'when the record exists' do
        before { put "/todos/#{todo_id}", params: valid_attributes }

        it 'updates the record' do
            expect(response.body).to be_empty
        end

        it 'returns status code 204' do
            expect(response).to have_http_status(204)
        end
        end
    end

    # Test suite for DELETE /todos/:id
    describe 'DELETE /todos/:id' do
        before { delete "/todos/#{todo_id}" }

        it 'returns status code 204' do
        expect(response).to have_http_status(204)
        end
    end
    end

    ```

22. We start by populating the database with a list of 10 todo records (factory bot). 
    We also have a custom helper method json which parses the JSON response to a Ruby Hash 
    which is easier to work with in our tests. Let's define it in `spec/support/request_spec_helper`.
    ```
    $ mkdir spec/support && touch spec/support/request_spec_helper.rb
    ```
    
    then define `spec/support/request_spec_helper.rb`.
    ```ruby
    module RequestSpecHelper
        # Parse JSON response to ruby hash
        def json
            JSON.parse(response.body)
        end
    end
    ```

23. The support directory is not autoloaded by default. To enable this:
    - open the rails helper,
    - comment out the support directory auto-loading,
    - then include it as shared module for all request specs in the RSpec configuration block.

24. next
25. next
26. next
27. next
28. next
29. next
30. next

### Note
- dont do anything for spec_helper
- run command `gem install faker` for todoitems spec
- set `let(:json) { JSON(response.body) }` in top of todos_spec and items_spec

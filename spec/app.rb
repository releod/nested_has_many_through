# Testing app setup

##################
# Database schema
##################

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :users, :force => true do |t|
      t.column "type", :string
    end
    
    create_table :posts, :force => true do |t|
      t.column "author_id", :integer
      t.column "category_id", :integer
    end

    create_table :categories, :force => true do |t|
    end

    create_table :comments, :force => true do |t|
      t.column "user_id", :integer
      t.column "post_id", :integer
    end
  end
end

#########
# Models
#
# Domain model is this:
#
#   - authors (type of user) can create posts in categories
#   - users can comment on posts
#   - authors have similar_posts: posts in the same categories as ther posts
#   - authors have similar_authors: authors of the recommended_posts
#   - authors have posts_of_similar_authors: all posts by similar authors (not just the similar posts,
#                                            similar_posts is be a subset of this collection)
#   - authors have commenters: users who have commented on their posts
#
class User < ActiveRecord::Base
  has_many :comments
  has_many :commented_posts, :through => :comments, :source => :post, :uniq => true
  has_many :commented_authors, :through => :commented_posts, :source => :author, :uniq => true
  has_many :posts_of_interest, :through => :commented_authors, :source => :posts_of_similar_authors, :uniq => true
end

class Author < User
  has_many :posts
  has_many :categories, :through => :posts
  has_many :similar_posts, :through => :categories, :source => :posts
  has_many :similar_authors, :through => :similar_posts, :source => :author, :uniq => true
  has_many :posts_of_similar_authors, :through => :similar_authors, :source => :post, :uniq => true
  has_many :commenters, :through => :posts, :uniq => true
end

class Post < ActiveRecord::Base
  belongs_to :author
  belongs_to :category
  has_many :comments
  has_many :commenters, :through => :comments, :source => :user, :uniq => true
end

class Category < ActiveRecord::Base
  has_many :posts
end

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end
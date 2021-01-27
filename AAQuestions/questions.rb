require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
    attr_accessor :id, :fname, :lname

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
        data.map { |datum| User.new(datum) }
      end

    def self.find_by_id(id)
        user = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                users
            WHERE
                id = ?
        SQL
        return nil unless user.length > 0
        User.new(user.first)
    end

    def self.find_by_name(fname, lname)
        user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
            SELECT
                *
            FROM
                users
            WHERE
                fname = ? AND lname = ?
        SQL
        return nil unless user.length > 0
        User.new(user.first)
    end

    def initialize(user_info)
        @id = user_info['id']
        @fname = user_info['fname']
        @lname = user_info['lname']
    end


end

class Question
    attr_accessor :id, :title, :body, :associated_author

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
        data.map { |datum| Question.new(datum) }
    end

    def self.find_by_id(id)

        question = QuestionsDBConnection.instance.execute(<<-SQL, id)

            SELECT
                *
            FROM
                questions
            WHERE
                id = ?
        SQL
        return nil unless question.length > 0
        Question.new(question.first)
    end

    def self.find_by_author_id(author_id)
        author = User.find_by_id(id)
        raise '#{self} is not in database' unless author
        questions = QuestionsDBConnection.instance.execute(<<-SQL, author.id)
            SELECT
                *
            FROM
                questions
            WHERE
                associated_author = ?
        SQL
        return nil unless questions.length > 0
        questions.map {|question| Question.new(question) }
    end 

    def initialize(question_info)
        @id = question_info['id']
        @title = question_info['title']
        @body = question_info['body']
        @associated_author = question_info['associated_author']
    end
end


class Question_Follow
    attr_accessor :id, :users_id, :questions_id

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM question_follows")
        data.map { |datum| Question_Follow.new(datum) }
    end

    def self.find_by_id(id)
        question_follow = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_follows
            WHERE
                id = ?
        SQL
        return nil unless question_follow.length > 0
        Question_Follow.new(question_follow.first)
    end

    def initialize(question_follow_info)
        @id = question_follow_info['id']
        @users_id = question_follow_info['users_id']
        @questions_id = question_follow_info['questions_id']
    end
end

class Reply

    attr_accessor :id, :body, :users_id, :questions_id, :parent_reply_id 

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
        data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_id(id)
        reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                replies
            WHERE
                id = ?
        SQL
        return nil unless reply.length > 0
        Reply.new(reply.first)
    end

    def self.find_by_user_id(id)
        author = User.find_by_id(id)
        raise '#{self} is not in database' unless author
        replies = QuestionsDBConnection.instance.execute(<<-SQL, author.id)
            SELECT
                *
            FROM
                replies
            WHERE
                users_id = ?
        SQL
        return nil unless replies.length > 0
        replies.map {|reply| Reply.new(reply) }
    end 


    def self.find_by_question_id(id)
        question = Question.find_by_id(id)
        raise '#{self} is not in database' unless question
        replies = QuestionsDBConnection.instance.execute(<<-SQL, question.id)
            SELECT
                *
            FROM
                replies
            WHERE
                questions_id = ?
        SQL
        return nil unless replies.length > 0
        replies.map {|reply| Reply.new(reply) }
    end 

    def initialize(reply_info)
        @id = reply_info['id']
        @body = reply_info['body']
        @users_id = reply_info['users_id']
        @questions_id = reply_info['questions_id']
        @parent_reply_id = reply_info['parent_reply_id']
    end

end


class Question_Like

    attr_accessor :id, :users_id, :questions_id

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM question_likes")
        data.map { |datum| Question_Like.new(datum) }
    end

    def self.find_by_id(id)
        question_like = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_likes
            WHERE
                id = ?
        SQL
        return nil unless question_like.length > 0
        Question_Like.new(question_like.first)
    end


    def initialize(question_like_info)
        @id = question_like_info['id']
        @users_id = question_like_info['users_id']
        @questions_id = question_like_info['questions_id']
    end
end




require_relative 'include.rb'
require_relative 'questions.rb'
require_relative 'users.rb'
require_relative 'question_follows.rb'
require_relative 'question_likes.rb'

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
        raise "#{self} is not in database" unless author
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
        raise "#{self} is not in database" unless question
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

    def self.find_by_parent_reply_id(id)
        reply = Reply.find_by_id(id)
        raise "#{self} is not in database" unless reply
        child_replies = QuestionsDBConnection.instance.execute(<<-SQL, reply.id)
            SELECT
                *
            FROM
                replies
            WHERE
                parent_reply_id = ?
        SQL
        return nil unless child_replies.length > 0
        child_replies.map {|reply| Reply.new(reply) }
    end 

    def initialize(reply_info)
        @id = reply_info['id']
        @body = reply_info['body']
        @users_id = reply_info['users_id']
        @questions_id = reply_info['questions_id']
        @parent_reply_id = reply_info['parent_reply_id']
    end

    def author
        User.find_by_id(self.users_id)
    end

    def question
        Question.find_by_id(self.questions_id)
    end

    def parent_reply
        Reply.find_by_id(self.parent_reply_id)
    end

    def child_replies
        Reply.find_by_parent_reply_id(self.id)
    end

end
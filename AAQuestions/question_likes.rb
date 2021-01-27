require_relative 'include.rb'
require_relative 'questions.rb'
require_relative 'users.rb'
require_relative 'question_follows.rb'
require_relative 'replies.rb'

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

    def self.likers_for_question_id(question_id)
        question = Question.find_by_id(question_id)
        raise "#{self} is not in the database" unless question
        likers = QuestionsDBConnection.instance.execute(<<-SQL, question.id)
            SELECT 
                users.*
            FROM 
                users
            JOIN 
                question_likes ON users.id = question_likes.users_id
            WHERE 
                questions_id = ?
        SQL
        return nil unless likers.length > 0
        likers.map {|liker| User.new(liker) }
    end

    def self.num_likes_for_question_id(question_id)
        question = Question.find_by_id(question_id)
        raise "#{self} is not in the database" unless question
        num_likes = QuestionsDBConnection.instance.execute(<<-SQL, question.id)
            SELECT 
                COUNT(*) AS num_likes
            FROM 
                users
            JOIN 
                question_likes ON users.id = question_likes.users_id
            WHERE 
                questions_id = ?
        SQL
        return num_likes.first['num_likes']
    end

    def self.liked_questions_for_user_id(user_id)
        user = User.find_by_id(user_id)
        raise "#{self} is not in the database" unless user
        liked = QuestionsDBConnection.instance.execute(<<-SQL, user.id)
            SELECT 
                questions.*
            FROM 
                questions
            JOIN 
                question_likes ON questions.id = question_likes.questions_id
            WHERE 
                users_id = ?
        SQL
        return nil unless liked.length > 0
        liked.map {|question| Question.new(question) }
    end

    def self.most_liked_questions(n)
        data = QuestionsDBConnection.instance.execute(<<-SQL, n)
            SELECT 
                questions.*
            FROM
                questions
            JOIN
                question_likes ON questions.id = question_likes.questions_id
            GROUP BY 
                questions.id
            ORDER BY 
                COUNT(*) DESC
            LIMIT 
                ? 
        SQL
        data.map {|datum| Question.new(datum)}
    end


    def initialize(question_like_info)
        @id = question_like_info['id']
        @users_id = question_like_info['users_id']
        @questions_id = question_like_info['questions_id']
    end
end
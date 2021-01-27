require_relative 'include.rb'
require_relative 'questions.rb'
require_relative 'users.rb'
require_relative 'replies.rb'
require_relative 'question_likes.rb'

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

    def self.followers_for_question_id(question_id)
        question = Question.find_by_id(question_id)
        raise "#{self} is not in the database" unless question
        followers = QuestionsDBConnection.instance.execute(<<-SQL, question.id)
            SELECT 
                users.*
            FROM 
                users
            JOIN 
                question_follows ON users.id = question_follows.users_id
            WHERE 
                questions_id = ?
        SQL
        return nil unless followers.length > 0
        followers.map {|follower| User.new(follower) }
    end 

    def self.followed_questions_for_user_id(user_id)
        user = User.find_by_id(user_id)
        raise "#{self} is not in the database" unless user
        followed = QuestionsDBConnection.instance.execute(<<-SQL, user.id)
            SELECT 
                questions.*
            FROM 
                questions
            JOIN 
                question_follows ON questions.id = question_follows.questions_id
            WHERE 
                users_id = ?
        SQL
        return nil unless followed.length > 0
        followed.map {|question| Question.new(question) }
    end 


    def self.most_followed_questions(n)
        data = QuestionsDBConnection.instance.execute(<<-SQL, n)
            SELECT 
                questions.*
            FROM
                questions
            JOIN
                question_follows ON questions.id = question_follows.questions_id
            GROUP BY 
                questions.id
            ORDER BY 
                COUNT(*) DESC
            LIMIT 
                ? 
        SQL
        data.map {|datum| Question.new(datum)}
    end 


    def initialize(question_follow_info)
        @id = question_follow_info['id']
        @users_id = question_follow_info['users_id']
        @questions_id = question_follow_info['questions_id']
    end
end
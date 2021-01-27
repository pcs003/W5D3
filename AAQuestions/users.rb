require_relative 'include.rb'
require_relative 'questions.rb'
require_relative 'question_follows.rb'
require_relative 'replies.rb'
require_relative 'question_likes.rb'

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

    def authored_questions
        Question.find_by_author_id(self.id)
    end

    def authored_replies
        Reply.find_by_user_id(self.id)
    end

    def followed_questions
        Question_Follow.followed_questions_for_user_id(self.id)
    end 

    def liked_questions
        Question_Like.liked_questions_for_user_id(self.id)
    end

    def average_karma
        data = QuestionsDBConnection.instance.execute(<<-SQL, self.id)
            SELECT
                COUNT(DISTINCT(questions.id)) AS num_questions, COUNT(question_likes.id) AS num_likes
            FROM
                questions
            LEFT OUTER JOIN
                question_likes ON questions.id = question_likes.questions_id
            WHERE
                questions.associated_author = ?
        SQL
        data.first['num_likes'].to_f / data.first['num_questions'].to_f
    end

    def save 
        if self.id
            self.update
        else 
            self.insert
        end 
    end 

    def insert 
        QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname)
            INSERT INTO 
                users(fname, lname)
            VALUES
                (?,?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
    end  

    def update
        QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname, self.id)
            UPDATE
                users
            SET
                fname = ?, lname = ?
            WHERE
                id = ?
        SQL
    end 

end

# q1  lijun
# q1  parth
# q2  lijun
# q3  parth
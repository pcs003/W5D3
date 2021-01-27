require_relative 'include.rb'
require_relative 'users.rb'
require_relative 'question_follows.rb'
require_relative 'replies.rb'
require_relative 'question_likes.rb'



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
        author = User.find_by_id(author_id)
        raise "#{self} is not in database" unless author
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

    def self.most_followed(n)
        Question_Follow.most_followed_questions(n)
    end 

    def self.most_liked(n)
        Question_Like.most_liked_questions(n)
    end

    def initialize(question_info)
        @id = question_info['id']
        @title = question_info['title']
        @body = question_info['body']
        @associated_author = question_info['associated_author']
    end

    def author
        User.find_by_id(self.associated_author)
    end

    def replies
        Reply.find_by_question_id(self.id)
    end

    def followers
        Question_Follow.followers_for_question_id(self.id)
    end 

    def likers
        Question_Like.likers_for_question_id(self.id)
    end

    def num_likes
        Question_Like.num_likes_for_question_id(self.id)
    end

    def save 
        if self.id
            self.update
        else 
            self.insert
        end 
    end 

    def insert 
        QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.associated_author)
            INSERT INTO 
                questions(title, body, associated_author)
            VALUES
                (?,?,?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
    end  

    def update
        QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.associated_author,self.id)
            UPDATE
                questio
            SET
                title = ?, body = ?, associated_author = ?
            WHERE
                id = ?
        SQL
    end 

end
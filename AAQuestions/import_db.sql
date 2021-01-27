PRAGMA foreign_keys = ON;

drop table if exists question_likes;
drop table if exists replies;
drop table if exists question_follows;
drop table if exists questions;
drop table if exists users;

create table users(
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

create table questions(
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    associated_author INTEGER NOT NULL,
    FOREIGN KEY (associated_author) REFERENCES users(id)
);

create table question_follows(
    id INTEGER PRIMARY KEY,
    users_id INTEGER NOT NULL,
    questions_id INTEGER NOT NULL,
    FOREIGN KEY (users_id) REFERENCES users(id),
    FOREIGN KEY (questions_id) REFERENCES questions(id)
);

create table replies(
    id INTEGER PRIMARY KEY,
    body TEXT NOT NULL,
    users_id INTEGER NOT NULL,
    questions_id INTEGER NOT NULL,
    parent_reply_id INTEGER,
    FOREIGN KEY (users_id) REFERENCES users(id),
    FOREIGN KEY (questions_id) REFERENCES questions(id),
    FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

create table question_likes(
    id INTEGER PRIMARY KEY,
    users_id INTEGER NOT NULL,
    questions_id INTEGER NOT NULL,
    FOREIGN KEY (users_id) REFERENCES users(id),
    FOREIGN KEY (questions_id) REFERENCES questions(id)
);

INSERT INTO
    users(fname, lname)
VALUES
    ('Lijun','Gan'),
    ('Parth','Shah');

INSERT INTO
    questions(title,body,associated_author)
VALUES
    ('CSS','Please help',(SELECT id FROM users WHERE fname = 'Parth' AND lname = 'Shah')),
    ('SQL','Please help',(SELECT id FROM users WHERE fname = 'Parth' AND lname = 'Shah'));

INSERT INTO
    question_follows(users_id,questions_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Parth' AND lname = 'Shah'),(SELECT id FROM questions WHERE title = "SQL")),
    ((SELECT id FROM users WHERE fname = 'Parth' AND lname = 'Shah'),(SELECT id FROM questions WHERE title = "CSS"));

INSERT INTO
    replies(body, users_id, questions_id, parent_reply_id)
VALUES
    ('same', (SELECT id FROM users WHERE fname = 'Lijun' AND lname = 'Gan'),(SELECT id FROM questions WHERE title = "SQL"), NULL),
    ('rip', (SELECT id FROM users WHERE fname = 'Parth' AND lname = 'Shah'),(SELECT id FROM questions WHERE title = "CSS"),(SELECT id FROM replies WHERE body= "same"));
    

drop table if exists users;

create table users(
    id INTEGER PRIMARY KEY
    fname TEXT NOT NULL
    lname TEXT NOT NULL
);

drop table if exists questions;

create table questions(
    id INTEGER PRIMARY KEY
    title TEXT NOT NULL
    body TEXT NOT NULL
    associated_author INTEGER NOT NULL
    FOREIGN KEY (associated_author) REFERENCES users(id)
);

drop table if exists question_follows;

create table question_follows(
    id INTEGER PRIMARY KEY
    users_id INTEGER NOT NULL
    questions_id INTEGER NOT NULL
    FOREIGN KEY (users_id) REFERENCES users(id)
    FOREIGN KEY (questions_id) REFERENCES questions(id)
);

drop table if exists replies;

create table replies(
    id INTEGER PRIMARY KEY
    body TEXT NOT NULL
    users_id INTEGER NOT NULL
    questions_id INTEGER NOT NULL
    parent_reply_id INTEGER
    FOREIGN KEY (users_id) REFERENCES users(id)
    FOREIGN KEY (questions_id) REFERENCES questions(id)
    FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

drop table if exists question_likes;

create table question_likes(
    id INTEGER PRIMARY KEY
    users_id INTEGER NOT NULL
    questions_id INTEGER NOT NULL
    FOREIGN KEY (users_id) REFERENCES users(id)
    FOREIGN KEY (questions_id) REFERENCES questions(id)
);
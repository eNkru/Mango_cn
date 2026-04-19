class HiddenTitles < MG::Base
  def up : String
    <<-SQL
    -- add hidden column to titles
    ALTER TABLE titles ADD COLUMN hidden INTEGER NOT NULL DEFAULT 0;
    SQL
  end

  def down : String
    <<-SQL
    -- remove hidden column from titles
    ALTER TABLE titles RENAME TO tmp;

    CREATE TABLE titles (
      id TEXT NOT NULL,
      path TEXT NOT NULL,
      signature TEXT,
      unavailable INTEGER NOT NULL DEFAULT 0,
      sort_title TEXT
    );

    INSERT INTO titles
    SELECT id, path, signature, unavailable, sort_title
    FROM tmp;

    DROP TABLE tmp;

    -- recreate the indices
    CREATE UNIQUE INDEX titles_id_idx on titles (id);
    CREATE UNIQUE INDEX titles_path_idx on titles (path);

    -- recreate the foreign key constraint on tags
    ALTER TABLE tags RENAME TO tmp;

    CREATE TABLE tags (
      id TEXT NOT NULL,
      tag TEXT NOT NULL,
      UNIQUE (id, tag),
      FOREIGN KEY (id) REFERENCES titles (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    );

    INSERT INTO tags
    SELECT * FROM tmp;

    DROP TABLE tmp;

    CREATE INDEX tags_id_idx ON tags (id);
    CREATE INDEX tags_tag_idx ON tags (tag);
    SQL
  end
end

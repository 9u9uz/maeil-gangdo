CREATE TYPE "member_status" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'PENDING',
    'BANNED',
    'DELETED'
    );

CREATE TYPE "plan_status" AS ENUM (
    'PENDING',
    'IN_PROGRESS',
    'COMPLETED'
    );
CREATE TABLE "member"
(
    "id"         BIGSERIAL   NOT NULL,
    "name"       VARCHAR     NOT NULL,
    "email"      VARCHAR     NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,63}$'),
    "sns_id"     SMALLSERIAL NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

COMMENT ON TABLE "member" IS '사용자';

CREATE UNIQUE INDEX "member_email_unique_index"
    ON "member" ("email");

CREATE INDEX "member_sns_id_index"
    ON "member" ("sns_id");

CREATE TABLE "lecture"
(
    "id"          BIGSERIAL   NOT NULL,
    "url"         TEXT        NOT NULL UNIQUE,
    "title"       VARCHAR     NOT NULL,
    "platform_id" SMALLSERIAL NOT NULL,
    "instructor"  VARCHAR     NOT NULL,
    "created_at"  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at"  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

COMMENT ON TABLE "lecture" IS '강의';

CREATE UNIQUE INDEX "lecture_url_unique_index"
    ON "lecture" ("url");

CREATE INDEX "lecture_platform_id_index"
    ON "lecture" ("platform_id");

CREATE TABLE "lesson"
(
    "id"         BIGSERIAL   NOT NULL,
    -- 섹션 내 수업의 인덱스
    "index"      SMALLINT    NOT NULL CHECK (index >= 0),
    "title"      VARCHAR     NOT NULL,
    "section_id" BIGSERIAL   NOT NULL,
    "duration"   INTERVAL    NOT NULL DEFAULT '0',
    "is_video"   BOOLEAN     NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

COMMENT ON TABLE "lesson" IS '수업';
COMMENT ON COLUMN lesson.index IS '섹션 내 수업의 인덱스';

CREATE UNIQUE INDEX "lesson_section_id_index_unique_index"
    ON "lesson" ("section_id", "index");

CREATE INDEX "lesson_section_id_index"
    ON "lesson" ("section_id");

CREATE TABLE "section"
(
    "id"         BIGSERIAL   NOT NULL,
    -- 단원(섹션)의 인덱스
    "index"      SMALLINT    NOT NULL CHECK (index >= 0),
    "title"      VARCHAR     NOT NULL,
    "lecture_id" BIGSERIAL   NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

COMMENT ON TABLE "section" IS '단원';
COMMENT ON COLUMN section.index IS '단원(섹션)의 인덱스';

CREATE UNIQUE INDEX "section_lecture_id_index_unique_index"
    ON "section" ("lecture_id", "index");

CREATE INDEX "section_lecture_id_index"
    ON "section" ("lecture_id");

CREATE TABLE "platform"
(
    "id"       SMALLSERIAL NOT NULL,
    "url"      TEXT        NOT NULL,
    "name"     VARCHAR     NOT NULL,
    "logo_url" TEXT,
    PRIMARY KEY ("id")
);

COMMENT ON TABLE "platform" IS '강의 플랫폼';


CREATE TABLE "plan"
(
    "id"          BIGSERIAL   NOT NULL,
    "platform_id" SMALLSERIAL NOT NULL,
    "member_id"   BIGSERIAL   NOT NULL,
    "title"       VARCHAR     NOT NULL,
    "created_at"  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at"  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status"      PLAN_STATUS NOT NULL DEFAULT 'PENDING',
    PRIMARY KEY ("id")
);

COMMENT ON TABLE "plan" IS '학습 계획';

CREATE INDEX "plan_member_id_index"
    ON "plan" ("member_id");

CREATE INDEX "plan_platform_id_index"
    ON "plan" ("platform_id");

CREATE TABLE "plan_item"
(
    "id"              BIGSERIAL   NOT NULL,
    "plan_id"         BIGSERIAL   NOT NULL,
    "start_lesson_id" BIGSERIAL   NOT NULL,
    "end_lesson_id"   BIGSERIAL   NOT NULL CHECK (start_lesson_id <= end_lesson_id),
    -- N일차, W주차 등 표시를 위한 인덱스
    "index"           SMALLINT    NOT NULL CHECK (index >= 0),
    "is_completed"    BOOLEAN     NOT NULL DEFAULT false,
    "created_at"      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at"      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

COMMENT ON TABLE "plan_item" IS '학습 범위 (액션 아이템)';
COMMENT ON COLUMN plan_item.index IS 'N일차, W주차 등 표시를 위한 인덱스';

CREATE INDEX "plan_item_plan_index"
    ON "plan_item" ("plan_id");

CREATE INDEX "plan_item_start_lesson_id_index"
    ON "plan_item" ("start_lesson_id");

CREATE INDEX "plan_item_end_lesson_id_index"
    ON "plan_item" ("end_lesson_id");

CREATE UNIQUE INDEX "plan_item_plan_id_index_unique_index"
    ON "plan_item" ("plan_id", "index");

CREATE TABLE "sns"
(
    "id"   SMALLSERIAL NOT NULL,
    "name" VARCHAR     NOT NULL UNIQUE,
    PRIMARY KEY ("id")
);


CREATE TABLE "notification_setting"
(
    "id"           BIGSERIAL   NOT NULL,
    "member_id"    BIGSERIAL   NOT NULL UNIQUE,
    "receive_push" BOOLEAN     NOT NULL DEFAULT true,
    "alert_time"   TIME        NOT NULL,
    "created_at"   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at"   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

COMMENT ON TABLE "notification_setting" IS '알림 설정';


ALTER TABLE "lecture"
    ADD FOREIGN KEY ("platform_id") REFERENCES "platform" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "section"
    ADD FOREIGN KEY ("lecture_id") REFERENCES "lecture" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "lesson"
    ADD FOREIGN KEY ("section_id") REFERENCES "section" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "plan"
    ADD FOREIGN KEY ("member_id") REFERENCES "member" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "plan"
    ADD FOREIGN KEY ("platform_id") REFERENCES "platform" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "plan_item"
    ADD FOREIGN KEY ("plan_id") REFERENCES "plan" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "plan_item"
    ADD FOREIGN KEY ("start_lesson_id") REFERENCES "lesson" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "plan_item"
    ADD FOREIGN KEY ("end_lesson_id") REFERENCES "lesson" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "member"
    ADD FOREIGN KEY ("sns_id") REFERENCES "sns" ("id")
        ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE "notification_setting"
    ADD FOREIGN KEY ("member_id") REFERENCES "member" ("id")
        ON UPDATE NO ACTION ON DELETE NO ACTION;
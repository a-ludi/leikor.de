CREATE TABLE "app_datas" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "value" text, "data_type" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "articles" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "article_number" varchar(255), "name" varchar(255), "description" text, "price" float, "subcategory_id" integer, "created_at" datetime, "updated_at" datetime, "picture_file_name" varchar(255), "picture_content_type" varchar(255), "picture_file_size" integer, "picture_updated_at" datetime);
CREATE TABLE "categories" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "category_id" integer, "created_at" datetime, "updated_at" datetime, "type" varchar(255), "ord" integer);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "login" varchar(255), "password" varchar(255), "name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20111101071747');

INSERT INTO schema_migrations (version) VALUES ('20111101072001');

INSERT INTO schema_migrations (version) VALUES ('20111101072058');

INSERT INTO schema_migrations (version) VALUES ('20111107073909');

INSERT INTO schema_migrations (version) VALUES ('20111107075413');

INSERT INTO schema_migrations (version) VALUES ('20111107113401');

INSERT INTO schema_migrations (version) VALUES ('20111110095444');

INSERT INTO schema_migrations (version) VALUES ('20111110095714');

INSERT INTO schema_migrations (version) VALUES ('20111110103519');

INSERT INTO schema_migrations (version) VALUES ('20111113200310');

INSERT INTO schema_migrations (version) VALUES ('20111123182323');

INSERT INTO schema_migrations (version) VALUES ('20111123183939');

INSERT INTO schema_migrations (version) VALUES ('20111201101656');
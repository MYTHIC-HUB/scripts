-- SQL / MYTHIC_CHAT_SUPABASE.sql / PostgreSQL / Supabase REST
CREATE TABLE IF NOT EXISTS public.chat_users (
  user_id BIGINT PRIMARY KEY CHECK (user_id > 0),
  username TEXT NOT NULL CHECK (char_length(username) BETWEEN 1 AND 32),
  badge TEXT NOT NULL DEFAULT 'USER' CHECK (badge = 'USER'),
  last_seen TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  channel TEXT NOT NULL CHECK (channel IN ('Geral', 'Trading', 'Off-topic')),
  user_id BIGINT NOT NULL CHECK (user_id > 0),
  username TEXT NOT NULL CHECK (char_length(username) BETWEEN 1 AND 32),
  badge TEXT NOT NULL DEFAULT 'USER' CHECK (badge = 'USER'),
  content TEXT NOT NULL CHECK (char_length(btrim(content)) BETWEEN 1 AND 240),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS chat_users_last_seen_idx
  ON public.chat_users(last_seen DESC);
CREATE INDEX IF NOT EXISTS chat_messages_channel_created_idx
  ON public.chat_messages(channel, created_at DESC);
CREATE INDEX IF NOT EXISTS chat_messages_user_created_idx
  ON public.chat_messages(user_id, created_at DESC);

ALTER TABLE public.chat_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS chat_users_select_public ON public.chat_users;
DROP POLICY IF EXISTS chat_users_insert_public ON public.chat_users;
DROP POLICY IF EXISTS chat_users_update_public ON public.chat_users;
DROP POLICY IF EXISTS chat_messages_select_public ON public.chat_messages;
DROP POLICY IF EXISTS chat_messages_insert_public ON public.chat_messages;

CREATE POLICY chat_users_select_public ON public.chat_users
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY chat_users_insert_public ON public.chat_users
  FOR INSERT TO anon, authenticated WITH CHECK (badge = 'USER');
CREATE POLICY chat_users_update_public ON public.chat_users
  FOR UPDATE TO anon, authenticated
  USING (true) WITH CHECK (badge = 'USER');
CREATE POLICY chat_messages_select_public ON public.chat_messages
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY chat_messages_insert_public ON public.chat_messages
  FOR INSERT TO anon, authenticated
  WITH CHECK (badge = 'USER' AND char_length(btrim(content)) BETWEEN 1 AND 240);

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT ON public.chat_users, public.chat_messages TO anon, authenticated;
GRANT UPDATE (user_id, username, last_seen) ON public.chat_users TO anon, authenticated;
REVOKE DELETE ON public.chat_users, public.chat_messages FROM anon, authenticated;
REVOKE UPDATE ON public.chat_messages FROM anon, authenticated;

-- Server-time presence stamp and immutable ID/role.
CREATE OR REPLACE FUNCTION public.chat_stamp_user()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.user_id <> OLD.user_id THEN
      RAISE EXCEPTION 'user_id_imutavel';
    END IF;
  END IF;
  NEW.username := btrim(NEW.username);
  NEW.badge := 'USER';
  NEW.last_seen := now();
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS chat_stamp_user_trigger ON public.chat_users;
CREATE TRIGGER chat_stamp_user_trigger
BEFORE INSERT OR UPDATE ON public.chat_users
FOR EACH ROW EXECUTE FUNCTION public.chat_stamp_user();

-- Prevent quick repeats even from a modified client (per declared ID).
CREATE OR REPLACE FUNCTION public.chat_limit_messages()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  NEW.content := btrim(NEW.content);
  NEW.username := btrim(NEW.username);
  NEW.badge := 'USER';
  NEW.created_at := now();
  PERFORM pg_catalog.pg_advisory_xact_lock(NEW.user_id);
  IF EXISTS (
    SELECT 1 FROM public.chat_messages m
    WHERE m.user_id = NEW.user_id
      AND m.created_at > now() - interval '3 seconds'
  ) THEN
    RAISE EXCEPTION 'limite_3_segundos';
  END IF;
  IF NEW.content ~* '(https?://|www[.]|discord[.]gg/)' THEN
    RAISE EXCEPTION 'links_nao_permitidos';
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS chat_limit_messages_trigger ON public.chat_messages;
CREATE TRIGGER chat_limit_messages_trigger
BEFORE INSERT ON public.chat_messages
FOR EACH ROW EXECUTE FUNCTION public.chat_limit_messages();
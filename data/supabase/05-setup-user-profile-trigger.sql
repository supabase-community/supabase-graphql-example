CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  insert into public."Profile" (id, "avatarUrl", username)
  values (new.id, 'https://www.gravatar.com/avatar/' || md5(new.email) || '?d=mp', split_part(new.email, '@', 1) || '-' || floor(random() * 10000));
  return new;
end;
$function$

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

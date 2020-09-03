--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4 (Ubuntu 12.4-1.pgdg20.04+1)
-- Dumped by pg_dump version 12.4 (Ubuntu 12.4-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: last_day(date); Type: FUNCTION; Schema: public; Owner: atomicbomber
--

CREATE FUNCTION public.last_day(date) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
            SELECT (date_trunc('MONTH', $1) + INTERVAL '1 MONTH - 1 day')::DATE;
            $_$;


ALTER FUNCTION public.last_day(date) OWNER TO atomicbomber;

--
-- Name: week_of_month(date, integer); Type: FUNCTION; Schema: public; Owner: atomicbomber
--

CREATE FUNCTION public.week_of_month(p_date date, p_direction integer) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $_$
              SELECT CASE WHEN $2 >= 0 THEN
                CEIL(EXTRACT(DAY FROM $1) / 7)::INT
              ELSE
                0 - CEIL(
                  (EXTRACT(DAY FROM last_day($1)) - EXTRACT(DAY FROM $1) + 1) / 7
                )::INT
              END
            $_$;


ALTER FUNCTION public.week_of_month(p_date date, p_direction integer) OWNER TO atomicbomber;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO atomicbomber;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.failed_jobs_id_seq OWNER TO atomicbomber;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: kegiatan; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.kegiatan (
    id integer NOT NULL,
    tanggal_mulai date NOT NULL,
    tanggal_selesai date NOT NULL,
    waktu_mulai time(0) without time zone,
    waktu_selesai time(0) without time zone,
    berulang boolean NOT NULL,
    kegiatan_sumber_id integer,
    ruangan_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    mata_kuliah_id integer
);


ALTER TABLE public.kegiatan OWNER TO atomicbomber;

--
-- Name: pola_perulangan; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.pola_perulangan (
    id integer NOT NULL,
    interval_perulangan integer NOT NULL,
    hari_dalam_minggu integer,
    minggu_dalam_bulan integer,
    hari_dalam_bulan integer,
    bulan_dalam_tahun integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    kegiatan_id integer NOT NULL
);


ALTER TABLE public.pola_perulangan OWNER TO atomicbomber;

--
-- Name: jadwal; Type: VIEW; Schema: public; Owner: atomicbomber
--

CREATE VIEW public.jadwal AS
 SELECT prefiltered_events.id_kegiatan AS kegiatan_id,
    prefiltered_events.rentang_waktu
   FROM ( SELECT
                CASE
                    WHEN scheduled_events.berulang THEN (((scheduled_events.row_number - 1) % (scheduled_events.interval_perulangan)::bigint) = 0)
                    ELSE true
                END AS included,
            scheduled_events.day_of_week,
            scheduled_events.day_of_month,
            scheduled_events.month_of_year,
            scheduled_events.week_of_month,
            scheduled_events.row_number,
            scheduled_events.rentang_waktu,
            scheduled_events.date,
            scheduled_events.id_kegiatan,
            scheduled_events.id,
            scheduled_events.tanggal_mulai,
            scheduled_events.tanggal_selesai,
            scheduled_events.waktu_mulai,
            scheduled_events.waktu_selesai,
            scheduled_events.berulang,
            scheduled_events.kegiatan_sumber_id,
            scheduled_events.ruangan_id,
            scheduled_events.created_at,
            scheduled_events.updated_at,
            scheduled_events.id_1 AS id,
            scheduled_events.interval_perulangan,
            scheduled_events.hari_dalam_minggu,
            scheduled_events.minggu_dalam_bulan,
            scheduled_events.hari_dalam_bulan,
            scheduled_events.bulan_dalam_tahun,
            scheduled_events.created_at_1 AS created_at,
            scheduled_events.updated_at_1 AS updated_at,
            scheduled_events.kegiatan_id
           FROM ( SELECT date_part('isodow'::text, schedule.date) AS day_of_week,
                    date_part('day'::text, schedule.date) AS day_of_month,
                    date_part('month'::text, schedule.date) AS month_of_year,
                    public.week_of_month((schedule.date)::date, 1) AS week_of_month,
                    row_number() OVER (PARTITION BY schedule.id_kegiatan ORDER BY schedule.date) AS row_number,
                        CASE
                            WHEN schedule.berulang THEN tsrange((schedule.date + (schedule.waktu_mulai)::interval), (schedule.date + (schedule.waktu_selesai)::interval))
                            ELSE tsrange((schedule.tanggal_mulai + schedule.waktu_mulai), (schedule.tanggal_selesai + schedule.waktu_selesai))
                        END AS rentang_waktu,
                    schedule.date,
                    schedule.id_kegiatan,
                    schedule.id,
                    schedule.tanggal_mulai,
                    schedule.tanggal_selesai,
                    schedule.waktu_mulai,
                    schedule.waktu_selesai,
                    schedule.berulang,
                    schedule.kegiatan_sumber_id,
                    schedule.ruangan_id,
                    schedule.created_at,
                    schedule.updated_at,
                    schedule.id_1 AS id,
                    schedule.interval_perulangan,
                    schedule.hari_dalam_minggu,
                    schedule.minggu_dalam_bulan,
                    schedule.hari_dalam_bulan,
                    schedule.bulan_dalam_tahun,
                    schedule.created_at_1 AS created_at,
                    schedule.updated_at_1 AS updated_at,
                    schedule.kegiatan_id
                   FROM ( SELECT generate_series((kegiatan_list.tanggal_mulai)::timestamp without time zone,
                                CASE
                                    WHEN (kegiatan_list.berulang = true) THEN (kegiatan_list.tanggal_selesai)::timestamp without time zone
                                    ELSE (kegiatan_list.tanggal_mulai)::timestamp without time zone
                                END, '1 day'::interval) AS date,
                            kegiatan_list.id_kegiatan,
                            kegiatan_list.id,
                            kegiatan_list.tanggal_mulai,
                            kegiatan_list.tanggal_selesai,
                            kegiatan_list.waktu_mulai,
                            kegiatan_list.waktu_selesai,
                            kegiatan_list.berulang,
                            kegiatan_list.kegiatan_sumber_id,
                            kegiatan_list.ruangan_id,
                            kegiatan_list.created_at,
                            kegiatan_list.updated_at,
                            kegiatan_list.id_1 AS id,
                            kegiatan_list.interval_perulangan,
                            kegiatan_list.hari_dalam_minggu,
                            kegiatan_list.minggu_dalam_bulan,
                            kegiatan_list.hari_dalam_bulan,
                            kegiatan_list.bulan_dalam_tahun,
                            kegiatan_list.created_at_1 AS created_at,
                            kegiatan_list.updated_at_1 AS updated_at,
                            kegiatan_list.kegiatan_id
                           FROM ( SELECT kegiatan.id AS id_kegiatan,
                                    kegiatan.id,
                                    kegiatan.tanggal_mulai,
                                    kegiatan.tanggal_selesai,
                                    kegiatan.waktu_mulai,
                                    kegiatan.waktu_selesai,
                                    kegiatan.berulang,
                                    kegiatan.kegiatan_sumber_id,
                                    kegiatan.ruangan_id,
                                    kegiatan.created_at,
                                    kegiatan.updated_at,
                                    pp.id,
                                    pp.interval_perulangan,
                                    pp.hari_dalam_minggu,
                                    pp.minggu_dalam_bulan,
                                    pp.hari_dalam_bulan,
                                    pp.bulan_dalam_tahun,
                                    pp.created_at,
                                    pp.updated_at,
                                    pp.kegiatan_id
                                   FROM (public.kegiatan
                                     LEFT JOIN public.pola_perulangan pp ON ((kegiatan.id = pp.kegiatan_id)))) kegiatan_list(id_kegiatan, id, tanggal_mulai, tanggal_selesai, waktu_mulai, waktu_selesai, berulang, kegiatan_sumber_id, ruangan_id, created_at, updated_at, id_1, interval_perulangan, hari_dalam_minggu, minggu_dalam_bulan, hari_dalam_bulan, bulan_dalam_tahun, created_at_1, updated_at_1, kegiatan_id)) schedule(date, id_kegiatan, id, tanggal_mulai, tanggal_selesai, waktu_mulai, waktu_selesai, berulang, kegiatan_sumber_id, ruangan_id, created_at, updated_at, id_1, interval_perulangan, hari_dalam_minggu, minggu_dalam_bulan, hari_dalam_bulan, bulan_dalam_tahun, created_at_1, updated_at_1, kegiatan_id)) scheduled_events(day_of_week, day_of_month, month_of_year, week_of_month, row_number, rentang_waktu, date, id_kegiatan, id, tanggal_mulai, tanggal_selesai, waktu_mulai, waktu_selesai, berulang, kegiatan_sumber_id, ruangan_id, created_at, updated_at, id_1, interval_perulangan, hari_dalam_minggu, minggu_dalam_bulan, hari_dalam_bulan, bulan_dalam_tahun, created_at_1, updated_at_1, kegiatan_id)
          WHERE (true AND
                CASE
                    WHEN (scheduled_events.hari_dalam_minggu IS NULL) THEN true
                    ELSE ((scheduled_events.hari_dalam_minggu)::double precision = scheduled_events.day_of_week)
                END AND
                CASE
                    WHEN (scheduled_events.minggu_dalam_bulan IS NULL) THEN true
                    ELSE (scheduled_events.minggu_dalam_bulan = scheduled_events.week_of_month)
                END AND
                CASE
                    WHEN (scheduled_events.hari_dalam_bulan IS NULL) THEN true
                    ELSE ((scheduled_events.hari_dalam_bulan)::double precision = scheduled_events.day_of_month)
                END AND
                CASE
                    WHEN (scheduled_events.bulan_dalam_tahun IS NULL) THEN true
                    ELSE ((scheduled_events.bulan_dalam_tahun)::double precision = scheduled_events.month_of_year)
                END)) prefiltered_events(included, day_of_week, day_of_month, month_of_year, week_of_month, row_number, rentang_waktu, date, id_kegiatan, id, tanggal_mulai, tanggal_selesai, waktu_mulai, waktu_selesai, berulang, kegiatan_sumber_id, ruangan_id, created_at, updated_at, id_1, interval_perulangan, hari_dalam_minggu, minggu_dalam_bulan, hari_dalam_bulan, bulan_dalam_tahun, created_at_1, updated_at_1, kegiatan_id)
  WHERE (prefiltered_events.included = true);


ALTER TABLE public.jadwal OWNER TO atomicbomber;

--
-- Name: kegiatan_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.kegiatan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kegiatan_id_seq OWNER TO atomicbomber;

--
-- Name: kegiatan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.kegiatan_id_seq OWNED BY public.kegiatan.id;


--
-- Name: kelas_mata_kuliah; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.kelas_mata_kuliah (
    id integer NOT NULL,
    kegiatan_id integer,
    mata_kuliah_id integer NOT NULL,
    tipe character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    tipe_semester_id integer NOT NULL,
    tahun_ajaran_id integer NOT NULL,
    program_studi_id integer NOT NULL
);


ALTER TABLE public.kelas_mata_kuliah OWNER TO atomicbomber;

--
-- Name: COLUMN kelas_mata_kuliah.tipe; Type: COMMENT; Schema: public; Owner: atomicbomber
--

COMMENT ON COLUMN public.kelas_mata_kuliah.tipe IS 'Kelas A, kelas B';


--
-- Name: kelas_mata_kuliah_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.kelas_mata_kuliah_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kelas_mata_kuliah_id_seq OWNER TO atomicbomber;

--
-- Name: kelas_mata_kuliah_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.kelas_mata_kuliah_id_seq OWNED BY public.kelas_mata_kuliah.id;


--
-- Name: mata_kuliah; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.mata_kuliah (
    id integer NOT NULL,
    nama character varying(255) NOT NULL,
    kode character varying(255) NOT NULL,
    semester integer NOT NULL,
    jumlah_sks integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    program_studi_id integer
);


ALTER TABLE public.mata_kuliah OWNER TO atomicbomber;

--
-- Name: mata_kuliah_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.mata_kuliah_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mata_kuliah_id_seq OWNER TO atomicbomber;

--
-- Name: mata_kuliah_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.mata_kuliah_id_seq OWNED BY public.mata_kuliah.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO atomicbomber;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO atomicbomber;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.password_resets (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_resets OWNER TO atomicbomber;

--
-- Name: pola_perulangan_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.pola_perulangan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pola_perulangan_id_seq OWNER TO atomicbomber;

--
-- Name: pola_perulangan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.pola_perulangan_id_seq OWNED BY public.pola_perulangan.id;


--
-- Name: program_studi; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.program_studi (
    id integer NOT NULL,
    nama character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.program_studi OWNER TO atomicbomber;

--
-- Name: program_studi_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.program_studi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_studi_id_seq OWNER TO atomicbomber;

--
-- Name: program_studi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.program_studi_id_seq OWNED BY public.program_studi.id;


--
-- Name: ruangan; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.ruangan (
    id integer NOT NULL,
    nama character varying(255) NOT NULL,
    deskripsi text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.ruangan OWNER TO atomicbomber;

--
-- Name: ruangan_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.ruangan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ruangan_id_seq OWNER TO atomicbomber;

--
-- Name: ruangan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.ruangan_id_seq OWNED BY public.ruangan.id;


--
-- Name: tahun_ajaran; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.tahun_ajaran (
    id integer NOT NULL,
    tahun_mulai integer NOT NULL,
    tahun_selesai integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.tahun_ajaran OWNER TO atomicbomber;

--
-- Name: tahun_ajaran_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.tahun_ajaran_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tahun_ajaran_id_seq OWNER TO atomicbomber;

--
-- Name: tahun_ajaran_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.tahun_ajaran_id_seq OWNED BY public.tahun_ajaran.id;


--
-- Name: tipe_semester; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.tipe_semester (
    id integer NOT NULL,
    nama character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.tipe_semester OWNER TO atomicbomber;

--
-- Name: tipe_semester_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.tipe_semester_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tipe_semester_id_seq OWNER TO atomicbomber;

--
-- Name: tipe_semester_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.tipe_semester_id_seq OWNED BY public.tipe_semester.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: atomicbomber
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255),
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.users OWNER TO atomicbomber;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: atomicbomber
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO atomicbomber;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atomicbomber
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: kegiatan id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kegiatan ALTER COLUMN id SET DEFAULT nextval('public.kegiatan_id_seq'::regclass);


--
-- Name: kelas_mata_kuliah id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kelas_mata_kuliah ALTER COLUMN id SET DEFAULT nextval('public.kelas_mata_kuliah_id_seq'::regclass);


--
-- Name: mata_kuliah id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.mata_kuliah ALTER COLUMN id SET DEFAULT nextval('public.mata_kuliah_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: pola_perulangan id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.pola_perulangan ALTER COLUMN id SET DEFAULT nextval('public.pola_perulangan_id_seq'::regclass);


--
-- Name: program_studi id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.program_studi ALTER COLUMN id SET DEFAULT nextval('public.program_studi_id_seq'::regclass);


--
-- Name: ruangan id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.ruangan ALTER COLUMN id SET DEFAULT nextval('public.ruangan_id_seq'::regclass);


--
-- Name: tahun_ajaran id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.tahun_ajaran ALTER COLUMN id SET DEFAULT nextval('public.tahun_ajaran_id_seq'::regclass);


--
-- Name: tipe_semester id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.tipe_semester ALTER COLUMN id SET DEFAULT nextval('public.tipe_semester_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--



--
-- Data for Name: kegiatan; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.kegiatan VALUES (1, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (2, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (3, '2018-07-01', '2018-12-31', '09:30:00', '12:00:00', true, NULL, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (4, '2018-07-01', '2018-12-31', '10:15:00', '12:45:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (5, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (6, '2018-07-01', '2018-12-31', '13:30:00', '16:00:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (7, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (8, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (9, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (10, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (11, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (12, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (13, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (14, '2018-07-01', '2018-12-31', '10:02:00', '12:30:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (15, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (16, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (17, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (18, '2018-07-01', '2018-12-31', '08:10:00', '09:50:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (19, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (20, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (21, '2018-07-01', '2018-12-31', '10:30:00', '13:00:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (22, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 4, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (23, '2018-07-01', '2018-12-31', '13:01:00', '15:30:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (24, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (25, '2018-07-01', '2018-12-31', '07:30:00', '09:45:00', true, NULL, 5, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (26, '2018-07-01', '2018-12-31', '10:00:00', '11:30:00', true, NULL, 6, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (27, '2018-07-01', '2018-12-31', '11:00:00', '13:00:00', true, NULL, 7, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (28, '2018-07-01', '2018-12-31', '11:00:00', '13:00:00', true, NULL, 8, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (29, '2018-07-01', '2018-12-31', '11:00:00', '13:00:00', true, NULL, 9, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (30, '2018-07-01', '2018-12-31', '13:30:00', '15:10:00', true, NULL, 1, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (31, '2018-07-01', '2018-12-31', '13:30:00', '16:00:00', true, NULL, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (32, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 5, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (33, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 10, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (34, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (35, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 12, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (36, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 13, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (37, '2018-07-01', '2018-12-31', '09:30:00', '11:00:00', true, NULL, 14, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (38, '2018-07-01', '2018-12-31', '09:30:00', '12:00:00', true, NULL, 15, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (39, '2018-07-01', '2018-12-31', '09:30:00', '12:00:00', true, NULL, 5, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (40, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 16, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.kegiatan VALUES (41, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 12, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (42, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 14, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (43, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 17, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (44, '2018-07-01', '2018-12-31', '14:30:00', '16:00:00', true, NULL, 14, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (45, '2018-07-01', '2018-12-31', '14:30:00', '16:00:00', true, NULL, 17, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (46, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 16, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (47, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 18, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (48, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 3, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (49, '2018-07-01', '2018-12-31', '07:30:00', '09:29:00', true, NULL, 12, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (50, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 6, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (51, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 19, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (52, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 20, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (53, '2018-07-01', '2018-12-31', '09:30:00', '16:00:00', true, NULL, 21, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (54, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 18, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (55, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 22, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (56, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 5, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (57, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 16, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (58, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 14, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (59, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 19, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (60, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (61, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (62, '2018-07-01', '2018-12-31', '07:30:00', '09:29:00', true, NULL, 12, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (63, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 20, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (64, '2018-07-01', '2018-12-31', '09:30:00', '11:02:00', true, NULL, 12, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (65, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 6, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (66, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 19, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (67, '2018-07-01', '2018-12-31', '09:30:00', '16:00:00', true, NULL, 21, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (68, '2018-07-01', '2018-12-31', '10:02:00', '12:30:00', true, NULL, 20, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (69, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 23, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (70, '2018-07-01', '2018-12-31', '11:20:00', '13:00:00', true, NULL, 19, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (71, '2018-07-01', '2018-12-31', '13:02:00', '14:40:00', true, NULL, 24, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (72, '2018-07-01', '2018-12-31', '13:02:00', '14:40:00', true, NULL, 19, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (73, '2018-07-01', '2018-12-31', '13:02:00', '14:40:00', true, NULL, 20, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (74, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 10, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (75, '2018-07-01', '2018-12-31', '14:30:00', '16:10:00', true, NULL, 6, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (76, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 22, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (77, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 5, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (78, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 25, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (79, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 19, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (80, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 20, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (81, '2018-07-01', '2018-12-31', '09:30:00', '12:00:00', true, NULL, 3, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (82, '2018-07-01', '2018-12-31', '10:02:00', '11:40:00', true, NULL, 6, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (83, '2018-07-01', '2018-12-31', '10:02:00', '11:40:00', true, NULL, 12, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (84, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 25, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (85, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 8, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (86, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 11, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (87, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 19, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (88, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 20, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (89, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 14, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (90, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 17, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (91, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 7, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (92, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 16, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (93, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 26, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (94, '2018-07-01', '2018-12-31', '09:30:00', '11:30:00', true, NULL, 27, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (95, '2018-07-01', '2018-12-31', '13:30:00', '15:10:00', true, NULL, 9, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (96, '2018-07-01', '2018-12-31', '13:30:00', '15:10:00', true, NULL, 16, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (97, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 18, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (98, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 15, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (99, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 11, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (100, '2018-07-01', '2018-12-31', '10:30:00', '13:00:00', true, NULL, 6, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (101, '2018-07-01', '2018-12-31', '13:32:00', '15:10:00', true, NULL, 27, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.kegiatan VALUES (102, '2018-07-01', '2018-12-31', '13:30:00', '15:10:00', true, NULL, 22, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (103, '2018-07-01', '2018-12-31', '15:30:00', '17:10:00', true, NULL, 27, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (104, '2018-07-01', '2018-12-31', '15:32:00', '17:10:00', true, NULL, 28, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (105, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (106, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (107, '2018-07-01', '2018-12-31', '10:30:00', '13:00:00', true, NULL, 14, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (108, '2018-07-01', '2018-12-31', '10:30:00', '13:00:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (109, '2018-07-01', '2018-12-31', '13:30:00', '15:10:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (110, '2018-07-01', '2018-12-31', '15:30:00', '17:10:00', true, NULL, 14, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (111, '2018-07-01', '2018-12-31', '15:30:00', '17:10:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (112, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (113, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 5, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (114, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (115, '2018-07-01', '2018-12-31', '12:30:00', '15:10:00', true, NULL, 18, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (116, '2018-07-01', '2018-12-31', '12:30:00', '15:10:00', true, NULL, 11, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (117, '2018-07-01', '2018-12-31', '15:30:00', '17:10:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (118, '2018-07-01', '2018-12-31', '15:30:00', '17:10:00', true, NULL, 14, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (119, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 10, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (120, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (121, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (122, '2018-07-01', '2018-12-31', '10:30:00', '12:10:00', true, NULL, 29, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (123, '2018-07-01', '2018-12-31', '12:30:00', '15:10:00', true, NULL, 14, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (124, '2018-07-01', '2018-12-31', '12:30:00', '15:10:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (125, '2018-07-01', '2018-12-31', '15:30:00', '17:10:00', true, NULL, 14, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (126, '2018-07-01', '2018-12-31', '15:30:00', '17:10:00', true, NULL, 17, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (127, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 13, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (128, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 7, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (129, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (130, '2018-07-01', '2018-12-31', '10:30:00', '13:00:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (131, '2018-07-01', '2018-12-31', '10:30:00', '13:00:00', true, NULL, 8, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (132, '2018-07-01', '2018-12-31', '14:00:00', '15:30:00', true, NULL, 15, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (133, '2018-07-01', '2018-12-31', '14:00:00', '16:30:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (134, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 22, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (135, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 15, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (136, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (137, '2018-07-01', '2018-12-31', '10:30:00', '12:00:00', true, NULL, 15, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (138, '2018-07-01', '2018-12-31', '10:30:00', '13:00:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (139, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (140, '2018-07-01', '2018-12-31', '14:00:00', '15:40:00', true, NULL, 15, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (141, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 8, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (142, '2018-07-01', '2018-12-31', '07:30:00', '13:00:00', true, NULL, 15, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (143, '2018-07-01', '2018-12-31', '10:30:00', '12:59:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (144, '2018-07-01', '2018-12-31', '10:30:00', '13:00:00', true, NULL, 29, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (145, '2018-07-01', '2018-12-31', '13:30:00', '16:00:00', true, NULL, 15, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (146, '2018-07-01', '2018-12-31', '07:30:00', '09:59:00', true, NULL, 18, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (147, '2018-07-01', '2018-12-31', '09:30:00', '12:00:00', true, NULL, 15, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (148, '2018-07-01', '2018-12-31', '10:00:00', '11:30:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (149, '2018-07-01', '2018-12-31', '12:30:00', '15:00:00', true, NULL, 15, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (150, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (151, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (152, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 15, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (153, '2018-07-01', '2018-12-31', '10:01:00', '11:30:00', true, NULL, 24, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.kegiatan VALUES (154, '2018-07-01', '2018-12-31', '13:30:00', '16:00:00', true, NULL, 24, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (155, '2018-07-01', '2018-12-31', '16:01:00', '17:30:00', true, NULL, 30, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (156, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 23, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (157, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 29, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (158, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (159, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (160, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 31, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (161, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 14, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (162, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 10, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (163, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 20, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (164, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 18, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (165, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 19, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (166, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 9, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (167, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 11, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (168, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 23, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (169, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 29, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (170, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 13, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (171, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 19, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (172, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 20, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (173, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 18, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (174, '2018-07-01', '2018-12-31', '14:20:00', '16:00:00', true, NULL, 18, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (175, '2018-07-01', '2018-12-31', '14:20:00', '16:50:00', true, NULL, 12, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (176, '2018-07-01', '2018-12-31', '14:20:00', '16:50:00', true, NULL, 19, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (177, '2018-07-01', '2018-12-31', '14:20:00', '16:50:00', true, NULL, 20, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (178, '2018-07-01', '2018-12-31', '14:20:00', '16:50:00', true, NULL, 11, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (179, '2018-07-01', '2018-12-31', '14:20:00', '16:50:00', true, NULL, 9, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (180, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (181, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 27, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (182, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (183, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 13, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (184, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (185, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 26, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (186, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 5, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (187, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (188, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 26, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (189, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 5, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (190, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 11, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (191, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 23, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (192, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 16, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (193, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 7, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (194, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 13, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (195, '2018-07-01', '2018-12-31', '09:20:00', '11:00:00', true, NULL, 27, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (196, '2018-07-01', '2018-12-31', '11:10:00', '12:50:00', true, NULL, 27, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (197, '2018-07-01', '2018-12-31', '11:10:00', '12:50:00', true, NULL, 6, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (198, '2018-07-01', '2018-12-31', '11:10:00', '12:50:00', true, NULL, 16, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (199, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 7, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (200, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 27, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (201, '2018-07-01', '2018-12-31', '13:00:00', '14:40:00', true, NULL, 9, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (202, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 6, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (203, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 13, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (204, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 32, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (205, '2018-07-01', '2018-12-31', '13:00:00', '15:30:00', true, NULL, 3, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (206, '2018-07-01', '2018-12-31', '15:00:00', '16:40:00', true, NULL, 9, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (207, '2018-07-01', '2018-12-31', '15:00:00', '16:40:00', true, NULL, 7, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (208, '2018-07-01', '2018-12-31', '15:00:00', '16:40:00', true, NULL, 27, '2020-09-03 14:17:52', '2020-09-03 14:17:52', NULL);
INSERT INTO public.kegiatan VALUES (209, '2018-07-01', '2018-12-31', '15:00:00', '16:40:00', true, NULL, 19, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (210, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 10, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (211, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (212, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 27, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (213, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 25, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (214, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 22, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (215, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 26, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (216, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (217, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 13, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (218, '2018-07-01', '2018-12-31', '09:30:00', '12:00:00', true, NULL, 27, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (219, '2018-07-01', '2018-12-31', '09:30:00', '12:00:00', true, NULL, 9, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (220, '2018-07-01', '2018-12-31', '09:30:00', '12:00:00', true, NULL, 31, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (221, '2018-07-01', '2018-12-31', '09:30:00', '12:00:00', true, NULL, 13, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (222, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 6, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (223, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 13, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (224, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 8, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (225, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 9, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (226, '2018-07-01', '2018-12-31', '14:20:00', '16:00:00', true, NULL, 31, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (227, '2018-07-01', '2018-12-31', '14:20:00', '16:00:00', true, NULL, 7, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (228, '2018-07-01', '2018-12-31', '14:20:00', '16:50:00', true, NULL, 25, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (229, '2018-07-01', '2018-12-31', '14:20:00', '16:50:00', true, NULL, 3, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (230, '2018-07-01', '2018-12-31', '14:20:00', '16:50:00', true, NULL, 27, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (231, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (232, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (233, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 13, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (234, '2018-07-01', '2018-12-31', '07:30:00', '09:10:00', true, NULL, 23, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (235, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 31, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (236, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 16, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (237, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 12, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (238, '2018-07-01', '2018-12-31', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (239, '2018-07-01', '2018-12-31', '06:00:00', '08:00:00', true, NULL, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (240, '2018-07-01', '2018-12-31', '10:20:00', '12:00:00', true, NULL, 13, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (241, '2018-07-01', '2018-12-31', '10:20:00', '12:00:00', true, NULL, 11, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (242, '2018-07-01', '2018-12-31', '10:20:00', '12:00:00', true, NULL, 23, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (243, '2018-07-01', '2018-12-31', '10:20:00', '12:00:00', true, NULL, 10, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (244, '2018-07-01', '2018-12-31', '10:20:00', '12:00:00', true, NULL, 32, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (245, '2018-07-01', '2018-12-31', '10:20:00', '12:00:00', true, NULL, 18, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (246, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 7, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (247, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 6, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (248, '2018-07-01', '2018-12-31', '12:30:00', '14:10:00', true, NULL, 9, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (249, '2018-07-01', '2018-12-31', '14:20:00', '16:00:00', true, NULL, 31, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (250, '2018-07-01', '2018-12-31', '14:20:00', '16:00:00', true, NULL, 21, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (251, '2018-07-01', '2018-12-31', '14:41:00', '17:10:00', true, NULL, 7, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (252, '2018-07-01', '2018-12-31', '14:41:00', '17:10:00', true, NULL, 8, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (253, '2018-07-01', '2018-12-31', '14:41:00', '17:10:00', true, NULL, 9, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (254, '2018-07-01', '2018-12-31', '07:00:00', '09:00:00', true, NULL, 1, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (255, '2018-07-01', '2018-12-31', '08:00:00', '10:30:00', true, NULL, 19, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (256, '2018-07-01', '2018-12-31', '08:00:00', '10:30:00', true, NULL, 20, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (257, '2018-07-01', '2018-12-31', '08:00:00', '10:30:00', true, NULL, 25, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (258, '2018-07-01', '2018-12-31', '08:00:00', '10:30:00', true, NULL, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (259, '2018-07-01', '2018-12-31', '08:00:00', '10:30:00', true, NULL, 12, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (260, '2018-07-01', '2018-12-31', '08:00:00', '10:30:00', true, NULL, 18, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (261, '2018-07-01', '2018-12-31', '08:00:00', '10:30:00', true, NULL, 31, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (262, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 3, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (263, '2018-07-01', '2018-12-31', '09:30:00', '11:10:00', true, NULL, 29, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (264, '2018-07-01', '2018-12-31', '13:30:00', '15:10:00', true, NULL, 6, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (265, '2018-07-01', '2018-12-31', '13:30:00', '15:10:00', true, NULL, 19, '2020-09-03 14:17:53', '2020-09-03 14:17:53', NULL);
INSERT INTO public.kegiatan VALUES (266, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 2, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (267, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 33, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (268, '2019-07-01', '2019-12-31', '10:15:00', '12:45:00', true, NULL, 34, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (269, '2019-07-01', '2019-12-31', '10:15:00', '12:45:00', true, NULL, 35, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (270, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 1, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (271, '2019-07-01', '2019-12-31', '13:01:00', '15:30:00', true, NULL, 17, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (272, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 2, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (273, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 33, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (274, '2019-07-01', '2019-12-31', '10:15:00', '11:55:00', true, NULL, 2, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (275, '2019-07-01', '2019-12-31', '10:15:00', '11:55:00', true, NULL, 1, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (276, '2019-07-01', '2019-12-31', '13:01:00', '15:30:00', true, NULL, 2, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (277, '2019-07-01', '2019-12-31', '13:02:00', '15:30:00', true, NULL, 1, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (278, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 2, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (279, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 3, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (280, '2019-07-01', '2019-12-31', '10:15:00', '12:45:00', true, NULL, 31, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (281, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 33, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (282, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (283, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (284, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (285, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 18, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (286, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 33, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (287, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 19, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (288, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 20, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (289, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 3, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (290, '2019-07-01', '2019-12-31', '10:01:00', '12:30:00', true, NULL, 28, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (291, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 20, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (292, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 18, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (293, '2019-07-01', '2019-12-31', '13:01:00', '15:30:00', true, NULL, 8, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (294, '2019-07-01', '2019-12-31', '13:01:00', '15:30:00', true, NULL, 16, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (295, '2019-07-01', '2019-12-31', '15:31:00', '17:10:00', true, NULL, 8, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (296, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (297, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 36, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (298, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 8, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (299, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 35, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (300, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 37, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (301, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 7, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (302, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 38, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (303, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 20, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (304, '2019-07-01', '2019-12-31', '10:01:00', '12:30:00', true, NULL, 18, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (305, '2019-07-01', '2019-12-31', '10:01:00', '12:30:00', true, NULL, 37, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (306, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 37, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (307, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 19, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (308, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 5, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (309, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 27, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (310, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 33, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (311, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 6, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (312, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 19, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (313, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 20, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (314, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (315, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 27, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (316, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 12, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (317, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 14, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (318, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 17, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (319, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 25, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (320, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 2, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (321, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 26, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (322, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 16, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (323, '2019-07-01', '2019-12-31', '10:01:00', '12:30:00', true, NULL, 9, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (324, '2019-07-01', '2019-12-31', '13:01:00', '14:14:00', true, NULL, 19, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (325, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 20, '2020-09-03 14:17:54', '2020-09-03 14:17:54', NULL);
INSERT INTO public.kegiatan VALUES (326, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 11, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (327, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 12, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (328, '2019-07-01', '2019-12-31', '13:01:00', '15:00:00', true, NULL, 14, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (329, '2019-07-01', '2019-12-31', '15:01:00', '16:40:00', true, NULL, 7, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (330, '2019-07-01', '2019-12-31', '15:01:00', '16:40:00', true, NULL, 27, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (331, '2019-07-01', '2019-12-31', '15:01:00', '16:40:00', true, NULL, 6, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (332, '2019-07-01', '2019-12-31', '15:01:00', '16:40:00', true, NULL, 19, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (333, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 33, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (334, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 3, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (335, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (336, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (337, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 34, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (338, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 7, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (339, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 27, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (340, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 6, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (341, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 37, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (342, '2019-07-01', '2019-12-31', '10:02:00', '11:40:00', true, NULL, 19, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (343, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 16, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (344, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 30, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (345, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 17, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (346, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 19, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (347, '2019-07-01', '2019-12-31', '13:01:00', '14:40:00', true, NULL, 2, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (348, '2019-07-01', '2019-12-31', '15:01:00', '16:40:00', true, NULL, 33, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (349, '2019-07-01', '2019-12-31', '15:01:00', '16:40:00', true, NULL, 6, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (350, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (351, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 35, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (352, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (353, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 30, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (354, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (355, '2019-07-01', '2019-12-31', '09:20:00', '11:00:00', true, NULL, 33, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (356, '2019-07-01', '2019-12-31', '09:20:00', '11:00:00', true, NULL, 27, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (357, '2019-07-01', '2019-12-31', '11:00:00', '13:00:00', true, NULL, 7, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (358, '2019-07-01', '2019-12-31', '11:00:00', '13:00:00', true, NULL, 27, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (359, '2019-07-01', '2019-12-31', '11:00:00', '13:00:00', true, NULL, 8, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (360, '2019-07-01', '2019-12-31', '11:00:00', '13:00:00', true, NULL, 9, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (361, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 17, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (362, '2019-07-01', '2019-12-31', '10:30:00', '12:10:00', true, NULL, 25, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (363, '2019-07-01', '2019-12-31', '10:30:00', '13:00:00', true, NULL, 17, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (364, '2019-07-01', '2019-12-31', '13:30:00', '15:10:00', true, NULL, 27, '2020-09-03 14:17:55', '2020-09-03 14:17:55', NULL);
INSERT INTO public.kegiatan VALUES (365, '2019-07-01', '2019-12-31', '13:30:00', '15:10:00', true, NULL, 36, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (366, '2019-07-01', '2019-12-31', '15:30:00', '17:00:00', true, NULL, 15, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (367, '2019-07-01', '2019-12-31', '15:30:00', '17:10:00', true, NULL, 20, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (368, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 33, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (369, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (370, '2019-07-01', '2019-12-31', '10:30:00', '13:00:00', true, NULL, 14, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (371, '2019-07-01', '2019-12-31', '10:30:00', '13:00:00', true, NULL, 3, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (372, '2019-07-01', '2019-12-31', '13:30:00', '15:10:00', true, NULL, 14, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (373, '2019-07-01', '2019-12-31', '13:30:00', '15:10:00', true, NULL, 17, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (374, '2019-07-01', '2019-12-31', '15:30:00', '17:10:00', true, NULL, 14, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (375, '2019-07-01', '2019-12-31', '15:30:00', '17:10:00', true, NULL, 17, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (376, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 18, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (377, '2019-07-01', '2019-12-31', '10:30:00', '12:10:00', true, NULL, 17, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (378, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 17, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (379, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 2, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (380, '2019-07-01', '2019-12-31', '15:30:00', '17:10:00', true, NULL, 17, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (381, '2019-07-01', '2019-12-31', '15:30:00', '17:10:00', true, NULL, 2, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (382, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 25, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (383, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 12, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (384, '2019-07-01', '2019-12-31', '10:30:00', '12:10:00', true, NULL, 25, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (385, '2019-07-01', '2019-12-31', '10:30:00', '12:10:00', true, NULL, 12, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (386, '2019-07-01', '2019-12-31', '12:30:00', '15:10:00', true, NULL, 12, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (387, '2019-07-01', '2019-12-31', '15:30:00', '17:10:00', true, NULL, 12, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (388, '2019-07-01', '2019-12-31', '15:30:00', '17:10:00', true, NULL, 28, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (389, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 14, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (390, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 17, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (391, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 24, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (392, '2019-07-01', '2019-12-31', '10:30:00', '13:00:00', true, NULL, 24, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (393, '2019-07-01', '2019-12-31', '10:30:00', '13:00:00', true, NULL, 27, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (394, '2019-07-01', '2019-12-31', '10:30:00', '13:00:00', true, NULL, 39, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (395, '2019-07-01', '2019-12-31', '14:00:00', '15:40:00', true, NULL, 15, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (396, '2019-07-01', '2019-12-31', '14:00:00', '15:40:00', true, NULL, 24, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (397, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 33, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (398, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 7, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (399, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (400, '2019-07-01', '2019-12-31', '10:30:00', '13:00:00', true, NULL, 5, '2020-09-03 14:17:56', '2020-09-03 14:17:56', NULL);
INSERT INTO public.kegiatan VALUES (401, '2019-07-01', '2019-12-31', '10:30:00', '13:00:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (402, '2019-07-01', '2019-12-31', '13:31:00', '15:10:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (403, '2019-07-01', '2019-12-31', '13:31:00', '16:00:00', true, NULL, 15, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (404, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 33, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (405, '2019-07-01', '2019-12-31', '07:30:00', '13:00:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (406, '2019-07-01', '2019-12-31', '10:30:00', '13:00:00', true, NULL, 15, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (407, '2019-07-01', '2019-12-31', '13:30:00', '16:00:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (408, '2019-07-01', '2019-12-31', '07:30:00', '09:59:00', true, NULL, 11, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (409, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (410, '2019-07-01', '2019-12-31', '10:00:00', '11:40:00', true, NULL, 15, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (411, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (412, '2019-07-01', '2019-12-31', '13:00:00', '15:30:00', true, NULL, 11, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (413, '2019-07-01', '2019-12-31', '15:32:00', '17:00:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (414, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (415, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 12, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (416, '2019-07-01', '2019-12-31', '10:02:00', '11:30:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (417, '2019-07-01', '2019-12-31', '10:02:00', '11:30:00', true, NULL, 15, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (418, '2019-07-01', '2019-12-31', '13:30:00', '16:00:00', true, NULL, 15, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (419, '2019-07-01', '2019-12-31', '13:30:00', '16:00:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (420, '2019-07-01', '2019-12-31', '16:02:00', '17:30:00', true, NULL, 24, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (421, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 16, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (422, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 12, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (423, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 9, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (424, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (425, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 9, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (426, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 5, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (427, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 11, '2020-09-03 14:17:57', '2020-09-03 14:17:57', NULL);
INSERT INTO public.kegiatan VALUES (428, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 16, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (429, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 15, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (430, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 6, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (431, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 19, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (432, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (433, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 3, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (434, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 11, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (435, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 9, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (436, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 7, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (437, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 28, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (438, '2019-07-01', '2019-12-31', '14:20:00', '16:00:00', true, NULL, 9, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (439, '2019-07-01', '2019-12-31', '14:20:00', '16:00:00', true, NULL, 26, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (440, '2019-07-01', '2019-12-31', '14:20:00', '16:50:00', true, NULL, 7, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (441, '2019-07-01', '2019-12-31', '14:20:00', '16:50:00', true, NULL, 6, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (442, '2019-07-01', '2019-12-31', '14:20:00', '16:50:00', true, NULL, 19, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (443, '2019-07-01', '2019-12-31', '14:20:00', '16:50:00', true, NULL, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (444, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 23, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (445, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 26, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (446, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 9, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (447, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 5, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (448, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (449, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 17, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (450, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 11, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (451, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 26, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (452, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 23, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (453, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 27, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (454, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 31, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (455, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 6, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (456, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 19, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (457, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 26, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (458, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 23, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (459, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 40, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (460, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 36, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (461, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 7, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (462, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 6, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (463, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 34, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (464, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 31, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (465, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 27, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (466, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (467, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (468, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 9, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (469, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 5, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (470, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 8, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (471, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 26, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (472, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 40, '2020-09-03 14:17:58', '2020-09-03 14:17:58', NULL);
INSERT INTO public.kegiatan VALUES (473, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (474, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 5, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (475, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 8, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (476, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 7, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (477, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 27, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (478, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 6, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (479, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 19, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (480, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 36, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (481, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 34, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (482, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 41, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (483, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 36, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (484, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 7, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (485, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 27, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (486, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 6, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (487, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 26, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (488, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 8, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (489, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 9, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (490, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (491, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 17, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (492, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 26, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (493, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 27, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (494, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 23, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (495, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 6, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (496, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 9, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (497, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 35, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (498, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 11, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (499, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 29, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (500, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 26, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (501, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 23, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (502, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 20, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (503, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 7, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (504, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 27, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (505, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 5, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (506, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 11, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (507, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 29, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (508, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 26, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (509, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 8, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (510, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 7, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (511, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 9, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (512, '2019-07-01', '2019-12-31', '13:30:00', '15:10:00', true, NULL, 7, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (513, '2019-07-01', '2019-12-31', '13:30:00', '15:10:00', true, NULL, 27, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (514, '2019-07-01', '2019-12-31', '13:30:00', '15:10:00', true, NULL, 9, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (515, '2019-07-01', '2019-12-31', '13:30:00', '16:00:00', true, NULL, 18, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (516, '2019-07-01', '2019-12-31', '13:30:00', '16:00:00', true, NULL, 32, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (517, '2019-07-01', '2019-12-31', '13:30:00', '16:00:00', true, NULL, 25, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (518, '2019-07-01', '2019-12-31', '13:30:00', '16:00:00', true, NULL, 28, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (519, '2019-07-01', '2019-12-31', '16:02:00', '17:40:00', true, NULL, 9, '2020-09-03 14:17:59', '2020-09-03 14:17:59', NULL);
INSERT INTO public.kegiatan VALUES (520, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (521, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (522, '2019-01-01', '2019-06-30', '10:30:00', '12:10:00', true, NULL, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (523, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 1, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (524, '2019-01-01', '2019-06-30', '13:00:00', '15:30:00', true, NULL, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (525, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 25, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (526, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 1, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (527, '2019-01-01', '2019-06-30', '10:30:00', '12:10:00', true, NULL, 25, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (528, '2019-01-01', '2019-06-30', '10:30:00', '12:10:00', true, NULL, 1, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (529, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 25, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (530, '2019-01-01', '2019-06-30', '13:50:00', '15:30:00', true, NULL, 9, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (531, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (532, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (533, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (534, '2019-01-01', '2019-06-30', '13:02:00', '15:30:00', true, NULL, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (535, '2019-01-01', '2019-06-30', '13:02:00', '15:30:00', true, NULL, 1, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (536, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 28, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (537, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (538, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (539, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (540, '2019-01-01', '2019-06-30', '13:02:00', '15:30:00', true, NULL, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (541, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (542, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (543, '2019-01-01', '2019-06-30', '13:30:00', '16:00:00', true, NULL, 38, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (544, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (545, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 29, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (546, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (547, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 19, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (548, '2019-01-01', '2019-06-30', '10:00:00', '11:40:00', true, NULL, 6, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (549, '2019-01-01', '2019-06-30', '10:02:00', '11:40:00', true, NULL, 19, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (550, '2019-01-01', '2019-06-30', '10:02:00', '11:40:00', true, NULL, 12, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (551, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 7, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (552, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 27, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (553, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 6, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (554, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (555, '2019-01-01', '2019-06-30', '13:00:00', '15:30:00', true, NULL, 11, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (556, '2019-01-01', '2019-06-30', '15:32:00', '17:10:00', true, NULL, 7, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (557, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (558, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (559, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (560, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 29, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (561, '2019-01-01', '2019-06-30', '10:00:00', '11:40:00', true, NULL, 23, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (562, '2019-01-01', '2019-06-30', '10:00:00', '12:30:00', true, NULL, 12, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (563, '2019-01-01', '2019-06-30', '10:02:00', '11:40:00', true, NULL, 18, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (564, '2019-01-01', '2019-06-30', '10:02:00', '11:40:00', true, NULL, 8, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (565, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 5, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.kegiatan VALUES (566, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 7, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (567, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 6, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (568, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 6, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (569, '2019-01-01', '2019-06-30', '13:00:00', '15:30:00', true, NULL, 29, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (570, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (571, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 17, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (572, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (573, '2019-01-01', '2019-06-30', '07:30:00', '12:00:00', true, NULL, 21, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (574, '2019-01-01', '2019-06-30', '10:02:00', '11:40:00', true, NULL, 14, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (575, '2019-01-01', '2019-06-30', '10:02:00', '11:40:00', true, NULL, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (576, '2019-01-01', '2019-06-30', '10:02:00', '12:30:00', true, NULL, 12, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (577, '2019-01-01', '2019-06-30', '10:02:00', '12:30:00', true, NULL, 9, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (578, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 29, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (579, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 28, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (580, '2019-01-01', '2019-06-30', '13:02:00', '15:30:00', true, NULL, 9, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (581, '2019-01-01', '2019-06-30', '13:02:00', '15:30:00', true, NULL, 26, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (582, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (583, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (584, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 18, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (585, '2019-01-01', '2019-06-30', '07:30:00', '12:00:00', true, NULL, 21, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (586, '2019-01-01', '2019-06-30', '10:00:00', '11:40:00', true, NULL, 20, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (587, '2019-01-01', '2019-06-30', '10:00:00', '11:40:00', true, NULL, 18, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (588, '2019-01-01', '2019-06-30', '10:02:00', '11:40:00', true, NULL, 29, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (589, '2019-01-01', '2019-06-30', '10:02:00', '12:30:00', true, NULL, 12, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (590, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 7, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (591, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 27, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (592, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 6, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (593, '2019-01-01', '2019-06-30', '13:00:00', '15:30:00', true, NULL, 19, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (594, '2019-01-01', '2019-06-30', '13:02:00', '14:40:00', true, NULL, 20, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (595, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (596, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (597, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 6, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (598, '2019-01-01', '2019-06-30', '13:00:00', '14:30:00', true, NULL, 21, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (599, '2019-01-01', '2019-06-30', '13:30:00', '14:10:00', true, NULL, 19, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (600, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 18, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (601, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 9, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (602, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (603, '2019-01-01', '2019-06-30', '10:01:00', '11:40:00', true, NULL, 7, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (604, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 15, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (605, '2019-01-01', '2019-06-30', '13:00:00', '16:20:00', true, NULL, 24, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (606, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 27, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (607, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (608, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 24, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (609, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 27, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (610, '2019-01-01', '2019-06-30', '13:01:00', '16:20:00', true, NULL, 24, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (611, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (612, '2019-01-01', '2019-06-30', '10:30:00', '12:10:00', true, NULL, 15, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (613, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 24, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (614, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 19, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (615, '2019-01-01', '2019-06-30', '13:30:00', '16:00:00', true, NULL, 24, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (616, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:18:01', '2020-09-03 14:18:01', NULL);
INSERT INTO public.kegiatan VALUES (617, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (618, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 24, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (619, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 15, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (620, '2019-01-01', '2019-06-30', '13:30:00', '16:00:00', true, NULL, 24, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (621, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (622, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 15, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (623, '2019-01-01', '2019-06-30', '13:30:00', '16:00:00', true, NULL, 24, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (624, '2019-01-01', '2019-06-30', '13:30:00', '16:00:00', true, NULL, 15, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (625, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (626, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 25, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (627, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 18, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (628, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 28, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (629, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 26, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (630, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 9, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (631, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 20, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (632, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 25, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (633, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 18, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (634, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 19, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (635, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 20, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (636, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 5, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (637, '2019-01-01', '2019-06-30', '14:30:00', '16:10:00', true, NULL, 25, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (638, '2019-01-01', '2019-06-30', '14:30:00', '16:10:00', true, NULL, 12, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (639, '2019-01-01', '2019-06-30', '14:30:00', '16:10:00', true, NULL, 14, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (640, '2019-01-01', '2019-06-30', '14:30:00', '17:00:00', true, NULL, 19, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (641, '2019-01-01', '2019-06-30', '14:30:00', '17:00:00', true, NULL, 20, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (642, '2019-01-01', '2019-06-30', '14:30:00', '17:00:00', true, NULL, 32, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (643, '2019-01-01', '2019-06-30', '14:30:00', '17:00:00', true, NULL, 18, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (644, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (645, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (646, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 2, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (647, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (648, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 9, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (649, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (650, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (651, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 26, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (652, '2019-01-01', '2019-06-30', '09:30:00', '11:00:00', true, NULL, 9, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (653, '2019-01-01', '2019-06-30', '09:30:00', '11:00:00', true, NULL, 16, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (654, '2019-01-01', '2019-06-30', '09:30:00', '11:00:00', true, NULL, 17, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (655, '2019-01-01', '2019-06-30', '09:30:00', '11:00:00', true, NULL, 6, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (656, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 31, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (657, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 19, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (658, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 11, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (659, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 20, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (660, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', NULL);
INSERT INTO public.kegiatan VALUES (661, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 26, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (662, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 23, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (663, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 20, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (664, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 18, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (665, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 8, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (666, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 6, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (667, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 19, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (668, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 8, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (669, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 20, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (670, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 8, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (671, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (672, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (673, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (674, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 27, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (675, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 26, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (676, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 6, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (677, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 19, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (678, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 20, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (679, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 32, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (680, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 20, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (681, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 18, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (682, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 3, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (683, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 10, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (684, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 5, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (685, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 31, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (686, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 11, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (687, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 6, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (688, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 19, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (689, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 3, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (690, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 28, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (691, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 5, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (692, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 8, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (693, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 20, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (694, '2019-01-01', '2019-06-30', '15:20:00', '17:00:00', true, NULL, 18, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (695, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 27, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (696, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 8, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (697, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (698, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 26, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (699, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 9, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (700, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (701, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 27, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (702, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 31, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (703, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 8, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (704, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 6, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (705, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 28, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (706, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 19, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (707, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 5, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (708, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 11, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (709, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 28, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (710, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 12, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (711, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 23, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (712, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 26, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (713, '2019-01-01', '2019-06-30', '14:30:00', '16:10:00', true, NULL, 11, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (714, '2019-01-01', '2019-06-30', '14:30:00', '16:10:00', true, NULL, 29, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (715, '2019-01-01', '2019-06-30', '14:30:00', '16:10:00', true, NULL, 25, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (716, '2019-01-01', '2019-06-30', '14:30:00', '16:10:00', true, NULL, 23, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.kegiatan VALUES (717, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 5, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (718, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 11, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (719, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 12, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (720, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 26, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (721, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 19, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (722, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 20, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (723, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 18, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (724, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 7, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (725, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 27, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (726, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 6, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (727, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 11, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (728, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 5, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (729, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 14, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (730, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (731, '2019-01-01', '2019-06-30', '10:30:00', '12:10:00', true, NULL, 1, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (732, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (733, '2019-01-01', '2019-06-30', '13:30:00', '16:00:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (734, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 14, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (735, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (736, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 14, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (737, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (738, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 11, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (739, '2019-01-01', '2019-06-30', '15:31:00', '17:10:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (740, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 25, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (741, '2019-01-01', '2019-06-30', '10:30:00', '13:00:00', true, NULL, 29, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (742, '2019-01-01', '2019-06-30', '13:30:00', '16:00:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (743, '2019-01-01', '2019-06-30', '13:30:00', '16:00:00', true, NULL, 25, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (744, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (745, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (746, '2019-01-01', '2019-06-30', '10:30:00', '12:10:00', true, NULL, 14, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (747, '2019-01-01', '2019-06-30', '10:30:00', '12:10:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (748, '2019-01-01', '2019-06-30', '12:30:00', '14:10:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (749, '2019-01-01', '2019-06-30', '12:30:00', '15:00:00', true, NULL, 14, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (750, '2019-01-01', '2019-06-30', '15:30:00', '17:10:00', true, NULL, 14, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (751, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (752, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 17, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (753, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 18, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (754, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (755, '2020-01-01', '2020-06-30', '10:30:00', '12:10:00', true, NULL, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (756, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (757, '2020-01-01', '2020-06-30', '15:30:00', '17:10:00', true, NULL, 6, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (758, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 42, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (759, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 1, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (760, '2020-01-01', '2020-06-30', '10:30:00', '12:10:00', true, NULL, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (761, '2020-01-01', '2020-06-30', '10:30:00', '12:10:00', true, NULL, 1, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (762, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 12, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (763, '2020-01-01', '2020-06-30', '15:00:00', '17:30:00', true, NULL, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (764, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 25, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (765, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 1, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (766, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 1, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (767, '2020-01-01', '2020-06-30', '13:00:00', '15:30:00', true, NULL, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (768, '2020-01-01', '2020-06-30', '13:00:00', '15:30:00', true, NULL, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (769, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (770, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (771, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (772, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 1, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (773, '2020-01-01', '2020-06-30', '13:30:00', '15:10:00', true, NULL, 42, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (774, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (775, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 43, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.kegiatan VALUES (776, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 44, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (777, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 29, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (778, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (779, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 17, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (780, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 6, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (781, '2020-01-01', '2020-06-30', '07:00:00', '10:00:00', true, NULL, 19, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (782, '2020-01-01', '2020-06-30', '10:01:00', '11:40:00', true, NULL, 21, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (783, '2020-01-01', '2020-06-30', '10:01:00', '11:40:00', true, NULL, 3, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (784, '2020-01-01', '2020-06-30', '10:01:00', '11:40:00', true, NULL, 19, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (785, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 25, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (786, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 20, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (787, '2020-01-01', '2020-06-30', '10:02:00', '12:30:00', true, NULL, 18, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (788, '2020-01-01', '2020-06-30', '12:31:00', '14:10:00', true, NULL, 27, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (789, '2020-01-01', '2020-06-30', '12:31:00', '14:10:00', true, NULL, 17, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (790, '2020-01-01', '2020-06-30', '12:31:00', '14:10:00', true, NULL, 20, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (791, '2020-01-01', '2020-06-30', '12:31:00', '14:10:00', true, NULL, 16, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (792, '2020-01-01', '2020-06-30', '12:32:00', '14:10:00', true, NULL, 32, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (793, '2020-01-01', '2020-06-30', '15:30:00', '17:10:00', true, NULL, 7, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (794, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 45, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (795, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 17, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (796, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (797, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (798, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 46, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (799, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 26, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (800, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 21, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (801, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 17, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (802, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 21, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (803, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 45, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (804, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 27, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (805, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 14, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (806, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 29, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (807, '2020-01-01', '2020-06-30', '12:32:00', '14:10:00', true, NULL, 47, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (808, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 46, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (809, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 17, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (810, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 42, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (811, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (812, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 17, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (813, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 21, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (814, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 32, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (815, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 20, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (816, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 18, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (817, '2020-01-01', '2020-06-30', '10:02:00', '12:30:00', true, NULL, 14, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (818, '2020-01-01', '2020-06-30', '10:02:00', '12:30:00', true, NULL, 19, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (819, '2020-01-01', '2020-06-30', '13:02:00', '14:40:00', true, NULL, 28, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (820, '2020-01-01', '2020-06-30', '13:02:00', '14:40:00', true, NULL, 6, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (821, '2020-01-01', '2020-06-30', '13:02:00', '14:40:00', true, NULL, 17, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (822, '2020-01-01', '2020-06-30', '13:02:00', '15:30:00', true, NULL, 9, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (823, '2020-01-01', '2020-06-30', '13:02:00', '15:30:00', true, NULL, 48, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (824, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (825, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 29, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (826, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 8, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (827, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 20, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (828, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 21, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (829, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 18, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (830, '2020-01-01', '2020-06-30', '10:01:00', '12:30:00', true, NULL, 18, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (831, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 25, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (832, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 48, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (833, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 49, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (834, '2020-01-01', '2020-06-30', '13:01:00', '14:40:00', true, NULL, 42, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (835, '2020-01-01', '2020-06-30', '13:01:00', '14:40:00', true, NULL, 12, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (836, '2020-01-01', '2020-06-30', '13:02:00', '14:40:00', true, NULL, 42, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (837, '2020-01-01', '2020-06-30', '13:02:00', '14:40:00', true, NULL, 3, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (838, '2020-01-01', '2020-06-30', '13:02:00', '15:30:00', true, NULL, 27, '2020-09-03 14:18:05', '2020-09-03 14:18:05', NULL);
INSERT INTO public.kegiatan VALUES (839, '2020-01-01', '2020-06-30', '13:02:00', '15:30:00', true, NULL, 49, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (840, '2020-01-01', '2020-06-30', '15:30:00', '17:00:00', true, NULL, 48, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (841, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 21, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (842, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 3, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (843, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 3, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (844, '2020-01-01', '2020-06-30', '13:30:00', '15:10:00', true, NULL, 42, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (845, '2020-01-01', '2020-06-30', '13:30:00', '15:10:00', true, NULL, 42, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (846, '2020-01-01', '2020-06-30', '13:30:00', '15:10:00', true, NULL, 12, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (847, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 42, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (848, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (849, '2020-01-01', '2020-06-30', '10:30:00', '12:10:00', true, NULL, 36, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (850, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 6, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (851, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 14, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (852, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 42, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (853, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 14, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (854, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 14, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (855, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 2, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (856, '2020-01-01', '2020-06-30', '12:30:00', '15:00:00', true, NULL, 2, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (857, '2020-01-01', '2020-06-30', '15:30:00', '17:10:00', true, NULL, 3, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (858, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 20, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (859, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 6, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (860, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 14, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (861, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 32, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (862, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (863, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 17, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (864, '2020-01-01', '2020-06-30', '10:30:00', '12:10:00', true, NULL, 14, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (865, '2020-01-01', '2020-06-30', '10:30:00', '12:10:00', true, NULL, 17, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (866, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 14, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (867, '2020-01-01', '2020-06-30', '12:30:00', '15:00:00', true, NULL, 17, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (868, '2020-01-01', '2020-06-30', '15:30:00', '17:10:00', true, NULL, 17, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (869, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 28, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (870, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (871, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 27, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (872, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (873, '2020-01-01', '2020-06-30', '10:01:00', '11:40:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (874, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 6, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (875, '2020-01-01', '2020-06-30', '13:00:00', '16:20:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (876, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 18, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (877, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 15, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (878, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 15, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (879, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (880, '2020-01-01', '2020-06-30', '13:01:00', '16:20:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (881, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (882, '2020-01-01', '2020-06-30', '10:30:00', '12:10:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (883, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 15, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (884, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 42, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (885, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (886, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 42, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (887, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (888, '2020-01-01', '2020-06-30', '10:30:00', '12:10:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (889, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 15, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (890, '2020-01-01', '2020-06-30', '10:30:00', '13:00:00', true, NULL, 36, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (891, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 15, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (892, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (893, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (894, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 15, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (895, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 15, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (896, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 24, '2020-09-03 14:18:06', '2020-09-03 14:18:06', NULL);
INSERT INTO public.kegiatan VALUES (897, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 5, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (898, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 23, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (899, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 9, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (900, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (901, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 31, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (902, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 9, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (903, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 5, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (904, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 7, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (905, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 11, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (906, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 7, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (907, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 9, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (908, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 4, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (909, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 25, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (910, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 27, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (911, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 11, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (912, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 16, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (913, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 29, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (914, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 9, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (915, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 17, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (916, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 5, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (917, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 11, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (918, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 29, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (919, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (920, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 27, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (921, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 6, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (922, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (923, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 9, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (924, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (925, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 5, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (926, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 23, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (927, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 11, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (928, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 31, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (929, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 29, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (930, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 4, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (931, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 25, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (932, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 20, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (933, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 19, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (934, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 6, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (935, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 25, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (936, '2020-01-01', '2020-06-30', '12:30:00', '15:00:00', true, NULL, 50, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (937, '2020-01-01', '2020-06-30', '12:30:00', '15:00:00', true, NULL, 26, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (938, '2020-01-01', '2020-06-30', '12:30:00', '15:00:00', true, NULL, 7, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (939, '2020-01-01', '2020-06-30', '12:30:00', '15:00:00', true, NULL, 27, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (940, '2020-01-01', '2020-06-30', '12:30:00', '15:00:00', true, NULL, 6, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (941, '2020-01-01', '2020-06-30', '15:20:00', '17:00:00', true, NULL, 8, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (942, '2020-01-01', '2020-06-30', '15:20:00', '17:00:00', true, NULL, 9, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (943, '2020-01-01', '2020-06-30', '15:20:00', '17:00:00', true, NULL, 7, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (944, '2020-01-01', '2020-06-30', '15:20:00', '17:00:00', true, NULL, 27, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (945, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 7, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (946, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 27, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (947, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 9, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (948, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 5, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (949, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 6, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (950, '2020-01-01', '2020-06-30', '10:02:00', '12:30:00', true, NULL, 9, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (951, '2020-01-01', '2020-06-30', '10:02:00', '12:30:00', true, NULL, 11, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (952, '2020-01-01', '2020-06-30', '10:02:00', '12:30:00', true, NULL, 31, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (953, '2020-01-01', '2020-06-30', '10:02:00', '12:30:00', true, NULL, 5, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (954, '2020-01-01', '2020-06-30', '12:32:00', '15:00:00', true, NULL, 11, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (955, '2020-01-01', '2020-06-30', '12:32:00', '15:00:00', true, NULL, 29, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (956, '2020-01-01', '2020-06-30', '12:32:00', '15:00:00', true, NULL, 23, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (957, '2020-01-01', '2020-06-30', '12:32:00', '15:00:00', true, NULL, 26, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (958, '2020-01-01', '2020-06-30', '13:02:00', '14:40:00', true, NULL, 7, '2020-09-03 14:18:07', '2020-09-03 14:18:07', NULL);
INSERT INTO public.kegiatan VALUES (959, '2020-01-01', '2020-06-30', '13:02:00', '14:40:00', true, NULL, 27, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (960, '2020-01-01', '2020-06-30', '13:02:00', '14:40:00', true, NULL, 40, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (961, '2020-01-01', '2020-06-30', '13:02:00', '14:40:00', true, NULL, 19, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (962, '2020-01-01', '2020-06-30', '15:02:00', '16:40:00', true, NULL, 7, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (963, '2020-01-01', '2020-06-30', '15:02:00', '16:40:00', true, NULL, 4, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (964, '2020-01-01', '2020-06-30', '15:30:00', '17:10:00', true, NULL, 26, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (965, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 45, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (966, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (967, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 5, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (968, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 27, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (969, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 23, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (970, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 19, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (971, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 5, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (972, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 7, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (973, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 8, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (974, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 9, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (975, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 11, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (976, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 27, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (977, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 23, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (978, '2020-01-01', '2020-06-30', '10:02:00', '11:40:00', true, NULL, 29, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (979, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 8, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (980, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 9, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (981, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 5, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (982, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 11, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (983, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 40, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (984, '2020-01-01', '2020-06-30', '12:30:00', '14:10:00', true, NULL, 6, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (985, '2020-01-01', '2020-06-30', '14:20:00', '16:00:00', true, NULL, 6, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (986, '2020-01-01', '2020-06-30', '14:20:00', '16:00:00', true, NULL, 23, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (987, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 50, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (988, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 19, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (989, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 20, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (990, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 18, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (991, '2020-01-01', '2020-06-30', '14:30:00', '17:00:00', true, NULL, 7, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (992, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 27, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (993, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 6, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (994, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 19, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (995, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 20, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (996, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 18, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (997, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 9, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (998, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 7, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (999, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 23, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (1000, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 31, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (1001, '2020-01-01', '2020-06-30', '13:30:00', '15:10:00', true, NULL, 47, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (1002, '2020-01-01', '2020-06-30', '13:30:00', '15:10:00', true, NULL, 23, '2020-09-03 14:18:08', '2020-09-03 14:18:08', NULL);
INSERT INTO public.kegiatan VALUES (1003, '2020-01-01', '2020-06-30', '15:31:00', '17:10:00', true, NULL, 16, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1004, '2020-01-01', '2020-06-30', '15:31:00', '17:10:00', true, NULL, 15, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1005, '2020-01-01', '2020-06-30', '15:31:00', '17:10:00', true, NULL, 34, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1006, '2020-01-01', '2020-06-30', '15:31:00', '17:10:00', true, NULL, 7, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1007, '2020-01-01', '2020-06-30', '15:31:00', '17:10:00', true, NULL, 27, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1008, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 5, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1009, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 8, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1010, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 38, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1011, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 51, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1012, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 52, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1013, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 53, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1014, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 54, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1015, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 32, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1016, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 54, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1017, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 7, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1018, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 51, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1019, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 38, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1020, '2019-07-01', '2019-12-31', '12:30:00', '14:10:00', true, NULL, 33, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1021, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 51, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1022, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 55, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1023, '2019-07-01', '2019-12-31', '12:30:00', '15:00:00', true, NULL, 53, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1024, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 11, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1025, '2019-07-01', '2019-12-31', '15:20:00', '17:00:00', true, NULL, 27, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1026, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 52, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1027, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 51, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1028, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 54, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1029, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 38, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1030, '2019-07-01', '2019-12-31', '09:30:00', '11:10:00', true, NULL, 51, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1031, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 55, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1032, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 9, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1033, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 53, '2020-09-03 14:18:09', '2020-09-03 14:18:09', NULL);
INSERT INTO public.kegiatan VALUES (1034, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 53, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1035, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 38, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1036, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 8, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1037, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1038, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1039, '2019-07-01', '2019-12-31', '09:20:00', '11:50:00', true, NULL, 6, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1040, '2019-07-01', '2019-12-31', '10:01:00', '12:30:00', true, NULL, 8, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1041, '2019-07-01', '2019-12-31', '10:31:00', '12:11:00', true, NULL, 36, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1042, '2019-07-01', '2019-12-31', '13:00:00', '14:40:00', true, NULL, 12, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1043, '2019-07-01', '2019-12-31', '14:40:00', '16:20:00', true, NULL, 12, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1044, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 16, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1045, '2019-07-01', '2019-12-31', '09:11:00', '10:50:00', true, NULL, 35, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1046, '2019-07-01', '2019-12-31', '09:30:00', '12:00:00', true, NULL, 36, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1047, '2019-07-01', '2019-12-31', '10:40:00', '12:20:00', true, NULL, 8, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1048, '2019-07-01', '2019-12-31', '13:00:00', '14:40:00', true, NULL, 25, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1049, '2019-07-01', '2019-12-31', '13:00:00', '15:30:00', true, NULL, 16, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1050, '2019-07-01', '2019-12-31', '13:00:00', '14:40:00', true, NULL, 11, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1051, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 47, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1052, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 16, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1053, '2019-07-01', '2019-12-31', '09:30:00', '11:10:00', true, NULL, 32, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1054, '2019-07-01', '2019-12-31', '09:30:00', '11:10:00', true, NULL, 28, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1055, '2019-07-01', '2019-12-31', '10:01:00', '11:40:00', true, NULL, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1056, '2019-07-01', '2019-12-31', '10:05:00', '12:35:00', true, NULL, 47, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1057, '2019-07-01', '2019-12-31', '12:20:00', '14:00:00', true, NULL, 8, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1058, '2019-07-01', '2019-12-31', '12:20:00', '14:00:00', true, NULL, 32, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1059, '2019-07-01', '2019-12-31', '12:20:00', '14:00:00', true, NULL, 25, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1060, '2019-07-01', '2019-12-31', '14:40:00', '16:20:00', true, NULL, 12, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1061, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 5, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1062, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 18, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1063, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 33, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1064, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 56, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1065, '2019-07-01', '2019-12-31', '09:30:00', '11:10:00', true, NULL, 5, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1066, '2019-07-01', '2019-12-31', '10:31:00', '12:11:00', true, NULL, 14, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1067, '2019-07-01', '2019-12-31', '13:00:00', '14:40:00', true, NULL, 14, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1068, '2019-07-01', '2019-12-31', '13:00:00', '15:30:00', true, NULL, 35, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1069, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1070, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 25, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1071, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 18, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1072, '2019-07-01', '2019-12-31', '13:00:00', '15:30:00', true, NULL, 56, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1073, '2019-07-01', '2019-12-31', '13:30:00', '15:10:00', true, NULL, 8, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1074, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 20, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1075, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1076, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 36, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1077, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 17, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1078, '2020-01-01', '2020-06-30', '10:01:00', '11:40:00', true, NULL, 16, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1079, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 57, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1080, '2020-01-01', '2020-06-30', '13:00:00', '15:30:00', true, NULL, 28, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1081, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 12, '2020-09-03 14:18:10', '2020-09-03 14:18:10', NULL);
INSERT INTO public.kegiatan VALUES (1082, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 47, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1083, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 44, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1084, '2020-01-01', '2020-06-30', '08:00:00', '09:40:00', true, NULL, 43, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1085, '2020-01-01', '2020-06-30', '10:01:00', '11:40:00', true, NULL, 12, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1086, '2020-01-01', '2020-06-30', '10:01:00', '12:30:00', true, NULL, 47, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1087, '2020-01-01', '2020-06-30', '10:01:00', '12:30:00', true, NULL, 44, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1088, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 5, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1089, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 11, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1090, '2020-01-01', '2020-06-30', '15:00:00', '16:40:00', true, NULL, 47, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1091, '2020-01-01', '2020-06-30', '15:00:00', '17:30:00', true, NULL, 44, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1092, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 12, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1093, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 19, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1094, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 14, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1095, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 29, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1096, '2020-01-01', '2020-06-30', '10:01:00', '12:30:00', true, NULL, 7, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1097, '2020-01-01', '2020-06-30', '10:10:00', '12:40:00', true, NULL, 27, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1098, '2020-01-01', '2020-06-30', '13:00:00', '15:30:00', true, NULL, 12, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1099, '2020-01-01', '2020-06-30', '15:31:00', '17:30:00', true, NULL, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1100, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 28, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1101, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 16, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1102, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 49, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1103, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 46, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1104, '2020-01-01', '2020-06-30', '09:15:00', '10:55:00', true, NULL, 28, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1105, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 16, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1106, '2020-01-01', '2020-06-30', '13:00:00', '15:30:00', true, NULL, 56, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1107, '2020-01-01', '2020-06-30', '15:31:00', '17:10:00', true, NULL, 16, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1108, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 49, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1109, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 35, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1110, '2020-01-01', '2020-06-30', '09:20:00', '11:00:00', true, NULL, 49, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1111, '2020-01-01', '2020-06-30', '13:00:00', '15:30:00', true, NULL, 32, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1112, '2020-01-01', '2020-06-30', '13:30:00', '15:10:00', true, NULL, 14, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1113, '2020-01-01', '2020-06-30', '13:30:00', '15:10:00', true, NULL, 17, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1114, '2020-01-01', '2020-06-30', '15:31:00', '17:10:00', true, NULL, 14, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1115, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 58, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1116, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 23, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1117, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 35, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1118, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 59, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1119, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1120, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 58, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1121, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 23, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1122, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 59, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1123, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 33, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1124, '2019-07-01', '2019-12-31', '13:10:00', '15:40:00', true, NULL, 23, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1125, '2019-07-01', '2019-12-31', '13:10:00', '15:40:00', true, NULL, 35, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1126, '2019-07-01', '2019-12-31', '13:10:00', '15:40:00', true, NULL, 5, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1127, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 20, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1128, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 58, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1129, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 18, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.kegiatan VALUES (1130, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 59, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1131, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 58, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1132, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 25, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1133, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 47, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1134, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 44, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1135, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 59, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1136, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 8, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1137, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 47, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1138, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 44, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1139, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 20, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1140, '2019-07-01', '2019-12-31', '13:10:00', '15:40:00', true, NULL, 18, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1141, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 59, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1142, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 58, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1143, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 23, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1144, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 29, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1145, '2019-07-01', '2019-12-31', '09:20:00', '11:50:00', true, NULL, 33, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1146, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 23, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1147, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 29, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1148, '2019-07-01', '2019-12-31', '13:10:00', '15:40:00', true, NULL, 35, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1149, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 59, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1150, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 2, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1151, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 19, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1152, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 58, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1153, '2019-07-01', '2019-12-31', '09:20:00', '11:50:00', true, NULL, 32, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1154, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 47, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1155, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 2, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1156, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 59, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1157, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 58, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1158, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 8, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1159, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 5, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1160, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 32, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1161, '2019-07-01', '2019-12-31', '15:00:00', '17:30:00', true, NULL, 5, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1162, '2019-07-01', '2019-12-31', '15:00:00', '17:30:00', true, NULL, 25, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1163, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 59, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1164, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 23, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1165, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 47, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1166, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 58, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1167, '2019-07-01', '2019-12-31', '13:10:00', '14:50:00', true, NULL, 23, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1168, '2019-07-01', '2019-12-31', '13:10:00', '15:40:00', true, NULL, 11, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1169, '2019-07-01', '2019-12-31', '13:10:00', '15:40:00', true, NULL, 5, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1170, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 36, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1171, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 32, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1172, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 25, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1173, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 18, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.kegiatan VALUES (1174, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 33, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1175, '2019-07-01', '2019-12-31', '13:00:00', '15:30:00', true, NULL, 14, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1176, '2019-07-01', '2019-12-31', '15:31:00', '17:10:00', true, NULL, 14, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1177, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 12, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1178, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1179, '2019-07-01', '2019-12-31', '09:30:00', '11:10:00', true, NULL, 12, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1180, '2019-07-01', '2019-12-31', '10:30:00', '12:10:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1181, '2019-07-01', '2019-12-31', '13:00:00', '15:30:00', true, NULL, 12, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1182, '2019-07-01', '2019-12-31', '15:31:00', '17:11:00', true, NULL, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1183, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1184, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 35, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1185, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 20, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1186, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 25, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1187, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 20, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1188, '2019-07-01', '2019-12-31', '10:20:00', '12:00:00', true, NULL, 54, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1189, '2019-07-01', '2019-12-31', '13:00:00', '15:30:00', true, NULL, 18, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1190, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1191, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 36, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1192, '2019-07-01', '2019-12-31', '09:30:00', '11:10:00', true, NULL, 20, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1193, '2019-07-01', '2019-12-31', '09:30:00', '11:10:00', true, NULL, 18, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1194, '2019-07-01', '2019-12-31', '13:00:00', '14:40:00', true, NULL, 18, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1195, '2019-07-01', '2019-12-31', '15:00:00', '16:40:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1196, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 33, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1197, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1198, '2019-07-01', '2019-12-31', '09:20:00', '11:00:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1199, '2019-07-01', '2019-12-31', '13:30:00', '15:10:00', true, NULL, 6, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1200, '2019-07-01', '2019-12-31', '15:11:00', '16:50:00', true, NULL, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1201, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 23, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1202, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 27, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1203, '2019-01-01', '2019-06-30', '10:10:00', '11:50:00', true, NULL, 16, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1204, '2019-01-01', '2019-06-30', '10:10:00', '11:50:00', true, NULL, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1205, '2019-01-01', '2019-06-30', '13:00:00', '15:30:00', true, NULL, 54, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1206, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 51, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1207, '2019-01-01', '2019-06-30', '10:10:00', '11:50:00', true, NULL, 54, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1208, '2019-01-01', '2019-06-30', '10:10:00', '11:50:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1209, '2019-01-01', '2019-06-30', '13:00:00', '15:30:00', true, NULL, 17, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1210, '2019-01-01', '2019-06-30', '13:00:00', '15:30:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1211, '2019-01-01', '2019-06-30', '15:00:00', '16:40:00', true, NULL, 30, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1212, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1213, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 54, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1214, '2019-01-01', '2019-06-30', '10:10:00', '11:50:00', true, NULL, 16, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1215, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1216, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 54, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1217, '2019-01-01', '2019-06-30', '15:00:00', '16:40:00', true, NULL, 32, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1218, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 25, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1219, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 30, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.kegiatan VALUES (1220, '2019-01-01', '2019-06-30', '09:20:00', '11:50:00', true, NULL, 25, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1221, '2019-01-01', '2019-06-30', '10:10:00', '11:50:00', true, NULL, 54, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1222, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1223, '2019-01-01', '2019-06-30', '13:00:00', '14:40:00', true, NULL, 54, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1224, '2019-01-01', '2019-06-30', '13:00:00', '15:30:00', true, NULL, 18, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1225, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 25, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1226, '2019-01-01', '2019-06-30', '09:20:00', '11:00:00', true, NULL, 14, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1227, '2019-01-01', '2019-06-30', '09:20:00', '11:00:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1228, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1229, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 25, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1230, '2019-01-01', '2019-06-30', '13:30:00', '15:10:00', true, NULL, 36, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1231, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 16, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1232, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 28, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1233, '2020-01-01', '2020-06-30', '09:20:00', '11:50:00', true, NULL, 27, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1234, '2020-01-01', '2020-06-30', '10:10:00', '11:50:00', true, NULL, 28, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1235, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 12, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1236, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 16, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1237, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1238, '2020-01-01', '2020-06-30', '09:20:00', '11:50:00', true, NULL, 16, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1239, '2020-01-01', '2020-06-30', '09:20:00', '11:50:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1240, '2020-01-01', '2020-06-30', '13:00:00', '15:30:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1241, '2020-01-01', '2020-06-30', '13:00:00', '15:30:00', true, NULL, 16, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1242, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 16, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1243, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 36, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1244, '2020-01-01', '2020-06-30', '09:20:00', '11:00:00', true, NULL, 54, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1245, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 16, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1246, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 54, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1247, '2020-01-01', '2020-06-30', '15:00:00', '16:40:00', true, NULL, 28, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1248, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1249, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 25, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1250, '2020-01-01', '2020-06-30', '09:20:00', '11:00:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1251, '2020-01-01', '2020-06-30', '10:01:00', '11:40:00', true, NULL, 54, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1252, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1253, '2020-01-01', '2020-06-30', '13:00:00', '15:30:00', true, NULL, 25, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1254, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1255, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 25, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1256, '2020-01-01', '2020-06-30', '09:20:00', '11:00:00', true, NULL, 32, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1257, '2020-01-01', '2020-06-30', '13:00:00', '14:30:00', true, NULL, 36, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1258, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 57, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1259, '2020-01-01', '2020-06-30', '13:00:00', '14:40:00', true, NULL, 25, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1260, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 27, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1261, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 28, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1262, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 47, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1263, '2019-07-01', '2019-12-31', '10:10:00', '12:40:00', true, NULL, 12, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1264, '2019-07-01', '2019-12-31', '11:10:00', '12:50:00', true, NULL, 14, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.kegiatan VALUES (1265, '2019-07-01', '2019-12-31', '13:00:00', '14:40:00', true, NULL, 32, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1266, '2019-07-01', '2019-12-31', '13:00:00', '14:40:00', true, NULL, 54, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1267, '2019-07-01', '2019-12-31', '15:30:00', '17:10:00', true, NULL, 33, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1268, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 55, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1269, '2019-07-01', '2019-12-31', '09:20:00', '11:00:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1270, '2019-07-01', '2019-12-31', '09:20:00', '11:50:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1271, '2019-07-01', '2019-12-31', '12:20:00', '14:50:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1272, '2019-07-01', '2019-12-31', '12:20:00', '14:50:00', true, NULL, 32, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1273, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1274, '2019-07-01', '2019-12-31', '09:20:00', '11:50:00', true, NULL, 12, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1275, '2019-07-01', '2019-12-31', '09:20:00', '11:50:00', true, NULL, 14, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1276, '2019-07-01', '2019-12-31', '12:20:00', '14:50:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1277, '2019-07-01', '2019-12-31', '12:20:00', '14:50:00', true, NULL, 44, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1278, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1279, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1280, '2019-07-01', '2019-12-31', '10:10:00', '11:50:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1281, '2019-07-01', '2019-12-31', '12:20:00', '14:50:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1282, '2019-07-01', '2019-12-31', '12:20:00', '14:50:00', true, NULL, 25, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1283, '2019-07-01', '2019-12-31', '07:30:00', '09:10:00', true, NULL, 33, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1284, '2019-07-01', '2019-12-31', '07:30:00', '10:00:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1285, '2019-07-01', '2019-12-31', '13:30:00', '16:00:00', true, NULL, 19, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1286, '2019-07-01', '2019-12-31', '13:30:00', '16:00:00', true, NULL, 20, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1287, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 7, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1288, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1289, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 60, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1290, '2019-01-01', '2019-06-30', '09:30:00', '12:00:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1291, '2019-01-01', '2019-06-30', '12:20:00', '14:50:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1292, '2019-01-01', '2019-06-30', '12:20:00', '14:50:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1293, '2019-01-01', '2019-06-30', '15:30:00', '17:10:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1294, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1295, '2019-01-01', '2019-06-30', '07:30:00', '09:10:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1296, '2019-01-01', '2019-06-30', '09:30:00', '11:10:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1297, '2019-01-01', '2019-06-30', '12:20:00', '14:50:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1298, '2019-01-01', '2019-06-30', '12:20:00', '14:50:00', true, NULL, 28, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1299, '2019-01-01', '2019-06-30', '15:30:00', '17:10:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1300, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1301, '2019-01-01', '2019-06-30', '10:10:00', '11:50:00', true, NULL, 18, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1302, '2019-01-01', '2019-06-30', '10:10:00', '12:40:00', true, NULL, 25, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1303, '2019-01-01', '2019-06-30', '12:50:00', '14:30:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1304, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1305, '2019-01-01', '2019-06-30', '10:10:00', '11:50:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1306, '2019-01-01', '2019-06-30', '12:20:00', '14:50:00', true, NULL, 60, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1307, '2019-01-01', '2019-06-30', '12:20:00', '14:50:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1308, '2019-01-01', '2019-06-30', '15:00:00', '16:40:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1309, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 16, '2020-09-03 14:18:15', '2020-09-03 14:18:15', NULL);
INSERT INTO public.kegiatan VALUES (1310, '2019-01-01', '2019-06-30', '07:30:00', '10:00:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1311, '2019-01-01', '2019-06-30', '13:10:00', '15:40:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1312, '2019-01-01', '2019-06-30', '13:30:00', '16:00:00', true, NULL, 16, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1313, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 57, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1314, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 32, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1315, '2020-01-01', '2020-06-30', '09:30:00', '12:00:00', true, NULL, 32, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1316, '2020-01-01', '2020-06-30', '12:20:00', '14:50:00', true, NULL, 19, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1317, '2020-01-01', '2020-06-30', '12:20:00', '14:50:00', true, NULL, 3, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1318, '2020-01-01', '2020-06-30', '15:30:00', '17:10:00', true, NULL, 25, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1319, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 57, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1320, '2020-01-01', '2020-06-30', '07:30:00', '09:10:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1321, '2020-01-01', '2020-06-30', '09:30:00', '11:10:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1322, '2020-01-01', '2020-06-30', '12:20:00', '14:50:00', true, NULL, 3, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1323, '2020-01-01', '2020-06-30', '12:20:00', '14:50:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1324, '2020-01-01', '2020-06-30', '15:30:00', '17:10:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1325, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1326, '2020-01-01', '2020-06-30', '10:10:00', '11:50:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1327, '2020-01-01', '2020-06-30', '10:10:00', '12:40:00', true, NULL, 16, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1328, '2020-01-01', '2020-06-30', '12:50:00', '14:30:00', true, NULL, 36, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1329, '2020-01-01', '2020-06-30', '15:20:00', '17:50:00', true, NULL, 16, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1330, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 12, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1331, '2020-01-01', '2020-06-30', '10:10:00', '11:50:00', true, NULL, 16, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1332, '2020-01-01', '2020-06-30', '10:10:00', '12:40:00', true, NULL, 61, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1333, '2020-01-01', '2020-06-30', '12:20:00', '14:50:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1334, '2020-01-01', '2020-06-30', '12:10:00', '14:40:00', true, NULL, 2, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1335, '2020-01-01', '2020-06-30', '15:00:00', '16:40:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1336, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 16, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1337, '2020-01-01', '2020-06-30', '07:30:00', '10:00:00', true, NULL, 36, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);
INSERT INTO public.kegiatan VALUES (1338, '2020-01-01', '2020-06-30', '13:30:00', '16:00:00', true, NULL, 28, '2020-09-03 14:18:16', '2020-09-03 14:18:16', NULL);


--
-- Data for Name: kelas_mata_kuliah; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.kelas_mata_kuliah VALUES (1, 1, 1, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (2, 2, 2, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (3, 3, 3, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (4, 4, 4, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (5, 5, 5, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (6, 6, 6, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (7, 7, 7, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (8, 8, 8, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (9, 9, 9, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (10, 10, 10, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (11, 11, 11, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (12, 12, 12, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (13, 13, 13, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (14, 14, 14, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (15, 15, 15, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (16, 16, 16, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (17, 17, 17, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (18, 18, 18, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (19, 19, 19, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (20, 20, 20, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (21, 21, 21, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (22, 22, 22, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (23, 23, 23, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (24, 24, 24, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (25, 25, 25, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (26, 26, 26, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (27, 27, 2, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (28, 28, 2, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (29, 29, 2, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (30, 30, 27, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (31, 31, 28, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (32, 32, 2, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (33, 33, 29, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (34, 34, 29, 'B', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (35, 35, 30, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (36, 36, 31, 'B', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (37, 37, 32, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (38, 38, 33, 'B', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (39, 39, 34, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (40, 40, 35, 'A', '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (41, 41, 35, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (42, 42, 36, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (43, 43, 36, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (44, 44, 37, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (45, 45, 38, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (46, 46, 2, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (47, 47, 39, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (48, 48, 37, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (49, 49, 31, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (50, 50, 40, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (51, 51, 32, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (52, 52, 41, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (53, 53, 42, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (54, 54, 43, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (55, 55, 44, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (56, 56, 45, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (57, 57, 46, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (58, 58, 41, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (59, 59, 47, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (60, 60, 43, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (61, 61, 48, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (62, 62, 49, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (63, 63, 50, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (64, 64, 46, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (65, 65, 7, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (66, 66, 51, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (67, 67, 42, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (68, 68, 52, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (69, 69, 47, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (70, 70, 38, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (71, 71, 51, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (72, 72, 53, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (73, 73, 53, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (74, 74, 54, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (75, 75, 55, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (76, 76, 44, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (77, 77, 34, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (78, 78, 50, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (79, 79, 56, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (80, 80, 56, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (81, 81, 52, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (82, 82, 45, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (83, 83, 57, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (84, 84, 39, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (85, 85, 48, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (86, 86, 58, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (87, 87, 49, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (88, 88, 54, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (89, 89, 40, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (90, 90, 59, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (91, 91, 7, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (92, 92, 55, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (93, 93, 60, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (94, 94, 33, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (95, 27, 2, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (96, 28, 2, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (97, 29, 2, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (98, 95, 61, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (99, 95, 61, 'B', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (100, 96, 62, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (101, 97, 63, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (102, 98, 2, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (103, 99, 64, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (104, 100, 65, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (105, 101, 66, 'A', '2020-09-03 14:17:50', '2020-09-03 14:17:50', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (106, 102, 67, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (107, 103, 68, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (108, 104, 69, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (109, 105, 7, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (110, 106, 70, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (111, 107, 71, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (112, 108, 72, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (113, 109, 73, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (114, 110, 74, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (115, 111, 75, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (116, 112, 76, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (117, 113, 77, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (118, 114, 78, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (119, 115, 79, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (120, 116, 80, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (121, 117, 81, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (122, 118, 82, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (123, 119, 83, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (124, 120, 84, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (125, 121, 85, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (126, 122, 86, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (127, 123, 87, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (128, 124, 88, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (129, 125, 89, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (130, 126, 90, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (131, 127, 91, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (132, 27, 2, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (133, 28, 2, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (134, 29, 2, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (135, 128, 92, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (136, 129, 93, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (137, 130, 94, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (138, 131, 95, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (139, 132, 96, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (140, 133, 97, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (141, 134, 2, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (142, 135, 98, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (143, 136, 99, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (144, 137, 100, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (145, 138, 101, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (146, 139, 102, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (147, 140, 103, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (148, 141, 7, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (149, 142, 104, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (150, 143, 105, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (151, 144, 106, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (152, 145, 107, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (153, 146, 108, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (154, 147, 109, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (155, 148, 110, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (156, 149, 111, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (157, 150, 112, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (158, 151, 113, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (159, 152, 114, 'A', '2020-09-03 14:17:51', '2020-09-03 14:17:51', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (160, 153, 115, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (161, 27, 2, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (162, 28, 2, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (163, 29, 2, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (164, 154, 116, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (165, 155, 117, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (166, 156, 2, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (167, 157, 2, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (168, 158, 2, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (169, 159, 118, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (170, 160, 118, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (171, 161, 118, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (172, 162, 7, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (173, 163, 7, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (174, 164, 7, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (175, 165, 119, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (176, 166, 119, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (177, 166, 119, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (178, 167, 120, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (179, 168, 120, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (180, 169, 120, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (181, 170, 120, 'D', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (182, 171, 121, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (183, 172, 121, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (184, 173, 121, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (185, 174, 122, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (186, 175, 123, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (187, 176, 123, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (188, 177, 123, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (189, 178, 123, 'D', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (190, 179, 124, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (191, 180, 125, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (192, 181, 125, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (193, 182, 125, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (194, 183, 125, 'D', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (195, 184, 126, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (196, 185, 126, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (197, 186, 126, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (198, 187, 126, 'D', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (199, 188, 127, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (200, 189, 127, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (201, 190, 127, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (202, 191, 127, 'D', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (203, 192, 128, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (204, 193, 128, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (205, 194, 128, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (206, 195, 128, 'D', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (207, 196, 129, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (208, 197, 129, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (209, 198, 129, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (210, 199, 130, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (211, 200, 130, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (212, 201, 130, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (213, 202, 131, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (214, 203, 131, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (215, 204, 131, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (216, 205, 131, 'D', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (217, 206, 132, 'A', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (218, 207, 132, 'B', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (219, 208, 132, 'C', '2020-09-03 14:17:52', '2020-09-03 14:17:52', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (220, 209, 132, 'D', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (221, 210, 133, 'D', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (222, 211, 133, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (223, 212, 133, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (224, 213, 133, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (225, 214, 134, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (226, 215, 134, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (227, 216, 134, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (228, 217, 134, 'D', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (229, 218, 135, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (230, 219, 135, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (231, 220, 135, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (232, 221, 135, 'D', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (233, 222, 136, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (234, 223, 136, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (235, 224, 136, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (236, 225, 137, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (237, 226, 138, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (238, 227, 139, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (239, 228, 140, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (240, 229, 140, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (241, 230, 140, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (242, 231, 141, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (243, 232, 141, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (244, 233, 141, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (245, 234, 141, 'D', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (246, 235, 142, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (247, 236, 142, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (248, 237, 142, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (249, 238, 142, 'D', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (250, 239, 143, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (251, 240, 143, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (252, 241, 143, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (253, 242, 143, 'D', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (254, 243, 144, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (255, 244, 144, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (256, 245, 144, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (257, 246, 145, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (258, 247, 145, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (259, 248, 145, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (260, 249, 146, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (261, 250, 147, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (262, 251, 148, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (263, 252, 148, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (264, 253, 148, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (265, 254, 149, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (266, 255, 150, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (267, 256, 150, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (268, 257, 150, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (269, 258, 150, 'D', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (270, 259, 151, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (271, 260, 151, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (272, 261, 151, 'C', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (273, 262, 152, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (274, 263, 153, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (275, 27, 2, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (276, 28, 2, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (277, 29, 2, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (278, 264, 154, 'A', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (279, 265, 154, 'B', '2020-09-03 14:17:53', '2020-09-03 14:17:53', 1, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (280, 266, 1, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (281, 267, 2, 'Islm', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (282, 268, 4, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (283, 269, 3, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (284, 270, 5, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (285, 271, 6, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (286, 272, 26, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (287, 273, 7, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (288, 274, 21, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (289, 275, 10, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (290, 276, 11, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (291, 277, 155, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (292, 278, 28, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (293, 279, 19, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (294, 280, 17, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (295, 281, 2, 'Isl A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (296, 282, 43, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (297, 283, 35, 'C', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (298, 284, 36, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (299, 285, 54, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (300, 286, 2, 'Isl B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (301, 287, 52, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (302, 288, 41, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (303, 289, 53, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (304, 290, 49, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (305, 291, 48, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (306, 292, 41, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (307, 293, 52, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (308, 294, 50, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (309, 295, 48, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (310, 296, 56, 'C', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (311, 297, 35, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (312, 298, 39, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (313, 299, 60, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (314, 300, 50, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (315, 301, 40, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (316, 302, 29, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (317, 303, 53, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (318, 304, 31, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (319, 305, 54, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (320, 306, 55, 'C', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (321, 307, 37, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (322, 308, 36, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (323, 309, 46, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (324, 310, 7, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (325, 311, 40, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (326, 312, 29, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (327, 313, 58, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (328, 314, 55, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (329, 315, 56, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (330, 316, 37, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (331, 317, 38, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (332, 318, 34, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (333, 319, 35, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (334, 320, 39, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (335, 321, 156, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (336, 322, 38, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (337, 323, 49, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (338, 324, 43, 'A', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (339, 325, 55, 'B', '2020-09-03 14:17:54', '2020-09-03 14:17:54', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (340, 326, 32, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (341, 327, 46, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (342, 328, 31, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (343, 329, 40, 'C', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (344, 330, 45, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (345, 331, 32, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (346, 332, 47, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (347, 333, 2, 'Isl C', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (348, 334, 56, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (349, 335, 42, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (350, 336, 45, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (351, 337, 44, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (352, 338, 33, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (353, 339, 33, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (354, 340, 34, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (355, 341, 157, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (356, 342, 58, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (357, 343, 43, 'C', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (358, 344, 61, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (359, 345, 156, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (360, 346, 44, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (361, 347, 59, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (362, 348, 7, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (363, 349, 47, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (364, 350, 51, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (365, 351, 51, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (366, 352, 51, 'C', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (367, 353, 158, 'B', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (368, 354, 42, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (369, 355, 7, 'C', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (370, 356, 57, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (371, 357, 2, 'Budha', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (372, 358, 2, 'Hindu', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (373, 359, 2, 'Ktlik', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (374, 360, 2, 'Prtsn', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (375, 361, 88, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (376, 267, 2, 'Islm', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (377, 362, 64, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (378, 363, 79, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (379, 364, 66, 'A', '2020-09-03 14:17:55', '2020-09-03 14:17:55', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (380, 365, 69, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (381, 366, 67, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (382, 367, 68, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (383, 368, 7, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (384, 369, 70, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (385, 370, 71, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (386, 371, 72, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (387, 372, 91, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (388, 373, 73, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (389, 374, 74, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (390, 375, 86, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (391, 376, 76, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (392, 377, 78, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (393, 378, 87, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (394, 379, 63, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (395, 380, 81, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (396, 381, 82, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (397, 382, 83, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (398, 383, 84, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (399, 384, 85, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (400, 385, 75, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (401, 386, 80, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (402, 387, 89, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (403, 388, 90, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (404, 389, 65, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (405, 390, 77, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (406, 357, 2, 'Budha', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (407, 358, 2, 'Hindu', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (408, 359, 2, 'Ktlik', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (409, 360, 2, 'Prtsn', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (410, 391, 97, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (411, 392, 94, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (412, 393, 93, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (413, 394, 95, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (414, 395, 96, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (415, 396, 97, 'B', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (416, 397, 2, 'Islam', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (417, 398, 98, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (418, 399, 99, 'A', '2020-09-03 14:17:56', '2020-09-03 14:17:56', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (419, 400, 92, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (420, 401, 101, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (421, 402, 103, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (422, 403, 102, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (423, 404, 7, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (424, 405, 104, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (425, 406, 107, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (426, 407, 105, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (427, 408, 108, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (428, 409, 109, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (429, 410, 110, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (430, 411, 111, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (431, 412, 112, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (432, 413, 100, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (433, 414, 113, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (434, 415, 114, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (435, 416, 115, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (436, 417, 159, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (437, 357, 2, 'Budha', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (438, 358, 2, 'Hindu', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (439, 359, 2, 'Ktlk', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (440, 360, 2, 'Prtsn', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (441, 418, 116, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (442, 419, 106, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (443, 420, 117, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (444, 281, 2, 'Ism A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (445, 281, 2, 'Ism B', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (446, 281, 2, 'Ism C', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (447, 421, 160, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (448, 422, 160, 'B', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (449, 423, 160, 'C', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (450, 424, 160, 'D', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (451, 425, 161, 'A', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (452, 426, 161, 'B', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (453, 427, 161, 'C', '2020-09-03 14:17:57', '2020-09-03 14:17:57', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (454, 428, 161, 'D', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (455, 429, 162, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (456, 430, 163, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (457, 431, 163, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (458, 432, 163, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (459, 433, 163, 'D', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (460, 434, 164, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (461, 435, 164, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (462, 436, 164, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (463, 437, 164, 'D', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (464, 438, 165, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (465, 439, 165, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (466, 440, 166, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (467, 441, 166, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (468, 442, 166, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (469, 443, 166, 'D', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (470, 444, 167, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (471, 445, 167, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (472, 446, 167, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (473, 447, 168, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (474, 448, 168, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (475, 449, 169, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (476, 450, 169, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (477, 451, 169, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (478, 452, 169, 'D', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (479, 453, 170, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (480, 454, 170, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (481, 455, 170, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (482, 456, 170, 'D', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (483, 457, 171, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (484, 458, 171, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (485, 459, 171, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (486, 460, 171, 'D', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (487, 461, 172, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (488, 462, 172, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (489, 463, 172, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (490, 464, 172, 'D', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (491, 310, 7, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (492, 310, 7, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (493, 310, 7, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (494, 465, 173, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (495, 466, 174, 'A1', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (496, 467, 174, 'A2', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (497, 468, 174, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (498, 469, 174, 'C', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (499, 470, 174, 'D', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (500, 471, 175, 'A', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (501, 472, 175, 'B', '2020-09-03 14:17:58', '2020-09-03 14:17:58', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (502, 473, 175, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (503, 474, 176, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (504, 475, 176, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (505, 476, 176, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (506, 477, 176, 'D', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (507, 478, 177, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (508, 479, 177, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (509, 480, 177, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (510, 481, 177, 'D', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (511, 482, 178, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (512, 483, 178, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (513, 484, 179, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (514, 485, 179, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (515, 486, 179, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (516, 487, 179, 'D', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (517, 488, 180, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (518, 489, 180, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (519, 490, 181, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (520, 491, 181, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (521, 492, 181, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (522, 493, 181, 'D', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (523, 494, 182, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (524, 495, 182, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (525, 496, 182, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (526, 497, 183, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (527, 498, 173, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (528, 499, 184, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (529, 500, 184, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (530, 501, 184, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (531, 502, 184, 'D', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (532, 503, 185, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (533, 504, 185, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (534, 505, 186, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (535, 506, 186, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (536, 507, 186, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (537, 508, 186, 'D', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (538, 509, 187, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (539, 510, 187, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (540, 511, 187, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (541, 357, 2, 'Bdha', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (542, 358, 2, 'Hndu', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (543, 359, 2, 'Ktlk', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (544, 360, 2, 'Prtsn', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (545, 512, 188, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (546, 513, 188, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (547, 514, 188, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (548, 515, 189, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (549, 516, 189, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (550, 517, 189, 'C', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (551, 518, 189, 'D', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (552, 519, 190, 'A', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (553, 519, 190, 'B', '2020-09-03 14:17:59', '2020-09-03 14:17:59', 1, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (554, 520, 191, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (555, 521, 192, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (556, 522, 193, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (557, 523, 194, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (558, 524, 195, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (559, 525, 196, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (560, 526, 197, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (561, 527, 198, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (562, 528, 199, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (563, 529, 200, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (564, 530, 201, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (565, 531, 202, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (566, 532, 203, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (567, 533, 204, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (568, 534, 205, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (569, 535, 206, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (570, 536, 207, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (571, 537, 208, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (572, 538, 209, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (573, 539, 210, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (574, 540, 211, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (575, 541, 212, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (576, 542, 213, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (577, 543, 214, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (578, 544, 215, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (579, 545, 216, 'B', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (580, 546, 217, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (581, 547, 218, 'B', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (582, 548, 219, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (583, 549, 220, 'B', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (584, 550, 221, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (585, 551, 216, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (586, 552, 222, 'B', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (587, 553, 223, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (588, 554, 224, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (589, 555, 225, 'B', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (590, 556, 158, 'B', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (591, 557, 226, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (592, 558, 215, 'B', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (593, 559, 156, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (594, 560, 217, 'B', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (595, 561, 157, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (596, 562, 227, 'B', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (597, 563, 220, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (598, 564, 228, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (599, 565, 201, 'A', '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (600, 566, 229, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (601, 567, 223, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (602, 568, 230, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (603, 569, 218, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (604, 570, 226, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (605, 571, 156, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (606, 572, 225, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (607, 573, 231, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (608, 574, 222, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (609, 575, 232, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (610, 576, 233, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (611, 577, 234, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (612, 578, 229, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (613, 579, 235, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (614, 580, 233, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (615, 581, 234, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (616, 582, 236, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (617, 583, 221, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (618, 584, 237, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (619, 585, 231, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (620, 586, 201, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (621, 587, 230, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (622, 588, 236, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (623, 589, 227, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (624, 590, 238, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (625, 591, 238, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (626, 592, 239, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (627, 593, 237, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (628, 594, 240, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (629, 595, 196, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (630, 596, 241, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (631, 597, 240, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (632, 598, 241, 'B', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (633, 599, 158, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (634, 600, 196, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (635, 601, 242, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (636, 602, 243, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (637, 603, 244, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (638, 604, 245, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (639, 605, 246, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (640, 606, 247, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (641, 607, 248, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (642, 608, 249, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (643, 609, 250, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (644, 610, 251, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (645, 611, 252, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (646, 612, 253, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (647, 613, 254, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (648, 614, 196, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (649, 615, 255, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (650, 616, 201, 'A', '2020-09-03 14:18:01', '2020-09-03 14:18:01', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (651, 617, 256, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (652, 618, 257, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (653, 619, 258, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (654, 620, 259, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (655, 621, 260, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (656, 622, 261, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (657, 623, 262, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (658, 624, 263, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (659, 625, 264, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (660, 626, 264, 'B', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (661, 627, 264, 'C', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (662, 628, 264, 'D', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (663, 629, 265, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (664, 630, 266, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (665, 631, 266, 'B', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (666, 632, 266, 'C', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (667, 633, 266, 'D', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (668, 634, 267, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (669, 635, 267, 'B', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (670, 636, 267, 'C', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (671, 637, 201, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (672, 638, 201, 'B', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (673, 639, 201, 'C', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (674, 640, 268, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (675, 641, 268, 'B', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (676, 642, 268, 'C', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (677, 643, 268, 'D', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (678, 644, 269, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (679, 645, 269, 'B', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (680, 646, 269, 'C', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (681, 647, 269, 'D', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (682, 648, 270, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (683, 649, 270, 'B', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (684, 650, 270, 'C', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (685, 651, 270, 'D', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (686, 652, 271, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (687, 653, 271, 'B', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (688, 654, 271, 'C', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (689, 655, 271, 'D', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (690, 656, 272, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (691, 657, 273, 'A', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (692, 658, 273, 'B', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (693, 659, 273, 'C', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (694, 660, 273, 'D', '2020-09-03 14:18:02', '2020-09-03 14:18:02', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (695, 661, 274, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (696, 662, 275, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (697, 663, 276, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (698, 664, 276, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (699, 665, 276, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (700, 666, 277, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (701, 667, 277, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (702, 668, 277, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (703, 669, 277, 'D', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (704, 670, 278, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (705, 671, 278, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (706, 672, 278, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (707, 673, 279, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (708, 674, 280, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (709, 675, 280, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (710, 676, 280, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (711, 677, 281, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (712, 678, 282, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (713, 679, 283, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (714, 680, 284, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (715, 681, 284, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (716, 682, 284, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (717, 683, 284, 'D', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (718, 684, 285, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (719, 685, 285, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (720, 686, 285, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (721, 687, 286, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (722, 688, 286, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (723, 689, 286, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (724, 690, 286, 'D', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (725, 691, 287, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (726, 692, 287, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (727, 693, 287, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (728, 694, 287, 'D', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (729, 695, 288, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (730, 696, 288, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (731, 697, 288, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (732, 698, 288, 'D', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (733, 699, 289, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (734, 700, 289, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (735, 700, 289, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (736, 701, 290, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (737, 702, 290, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (738, 703, 290, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (739, 704, 291, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (740, 705, 291, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (741, 706, 291, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (742, 707, 292, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (743, 708, 292, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (744, 709, 292, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (745, 710, 292, 'D', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (746, 711, 293, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (747, 712, 294, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (748, 713, 295, 'A', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (749, 714, 295, 'B', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (750, 715, 295, 'C', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (751, 716, 295, 'D', '2020-09-03 14:18:03', '2020-09-03 14:18:03', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (752, 717, 296, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (753, 718, 296, 'B', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (754, 719, 296, 'C', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (755, 720, 296, 'D', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (756, 721, 297, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (757, 722, 297, 'B', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (758, 723, 297, 'C', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (759, 724, 196, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (760, 725, 196, 'B', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (761, 726, 196, 'C', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (762, 727, 298, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (763, 728, 298, 'B', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (764, 729, 201, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (765, 730, 299, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (766, 731, 300, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (767, 732, 297, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (768, 733, 301, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (769, 734, 196, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (770, 735, 302, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (771, 736, 303, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (772, 737, 304, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (773, 738, 305, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (774, 739, 306, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (775, 740, 307, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (776, 741, 308, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (777, 742, 309, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (778, 743, 310, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (779, 744, 311, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (780, 745, 312, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (781, 746, 313, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (782, 747, 314, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (783, 748, 315, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (784, 749, 316, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (785, 750, 317, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (786, 751, 318, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (787, 752, 319, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 1, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (788, 753, 191, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (789, 754, 192, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (790, 755, 195, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (791, 756, 194, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (792, 757, 193, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (793, 758, 196, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (794, 759, 197, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (795, 760, 198, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (796, 761, 199, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (797, 762, 200, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (798, 763, 211, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (799, 764, 202, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (800, 765, 203, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (801, 766, 204, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (802, 767, 205, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (803, 768, 206, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (804, 769, 207, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (805, 770, 208, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (806, 771, 209, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (807, 772, 210, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (808, 773, 201, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (809, 774, 212, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (810, 775, 213, 'A', '2020-09-03 14:18:04', '2020-09-03 14:18:04', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (811, 776, 214, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 2);
INSERT INTO public.kelas_mata_kuliah VALUES (812, 777, 222, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (813, 778, 241, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (814, 779, 229, 'C', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (815, 780, 227, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (816, 781, 218, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (817, 782, 215, 'C', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (818, 783, 240, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (819, 784, 224, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (820, 785, 216, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (821, 786, 217, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (822, 787, 225, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (823, 788, 238, 'C', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (824, 789, 158, '2018A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (825, 790, 220, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (826, 791, 219, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (827, 792, 216, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (828, 793, 226, 'C', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (829, 794, 226, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (830, 795, 236, 'C', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (831, 796, 241, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (832, 797, 61, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (833, 798, 217, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (834, 799, 223, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (835, 800, 215, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (836, 801, 158, '2019C', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (837, 802, 61, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (838, 803, 240, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (839, 804, 235, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (840, 805, 216, 'C', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (841, 806, 229, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (842, 807, 238, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (843, 808, 158, '2018B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (844, 809, 223, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (845, 810, 201, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (846, 811, 226, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (847, 812, 230, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (848, 813, 231, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (849, 814, 236, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (850, 815, 222, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (851, 816, 230, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (852, 817, 233, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (853, 818, 225, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (854, 819, 229, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (855, 820, 220, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (856, 821, 221, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (857, 822, 218, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (858, 823, 234, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (859, 824, 215, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (860, 825, 236, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (861, 826, 222, 'C', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (862, 827, 227, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (863, 828, 231, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (864, 829, 234, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (865, 830, 237, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (866, 831, 238, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (867, 832, 221, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (868, 833, 228, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (869, 834, 201, 'B', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (870, 835, 30, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (871, 836, 196, 'C', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (872, 837, 239, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (873, 838, 233, 'A', '2020-09-03 14:18:05', '2020-09-03 14:18:05', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (874, 839, 237, 'B', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (875, 840, 62, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (876, 841, 241, 'C', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (877, 842, 158, '2019A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (878, 843, 158, '2019B', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (879, 844, 201, 'C', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (880, 845, 196, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (881, 845, 196, 'B', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (882, 846, 232, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 3);
INSERT INTO public.kelas_mata_kuliah VALUES (883, 847, 201, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (884, 848, 299, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (885, 849, 300, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (886, 850, 297, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (887, 851, 301, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (888, 852, 196, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (889, 853, 302, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (890, 854, 303, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (891, 855, 304, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (892, 856, 305, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (893, 857, 319, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (894, 858, 307, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (895, 859, 308, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (896, 860, 316, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (897, 861, 310, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (898, 862, 311, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (899, 863, 312, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (900, 864, 313, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (901, 865, 314, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (902, 866, 315, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (903, 867, 309, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (904, 868, 317, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (905, 869, 318, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (906, 870, 306, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 4);
INSERT INTO public.kelas_mata_kuliah VALUES (907, 871, 242, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (908, 872, 243, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (909, 873, 244, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (910, 874, 245, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (911, 875, 246, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (912, 876, 247, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (913, 877, 248, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (914, 878, 249, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (915, 879, 250, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (916, 880, 251, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (917, 881, 252, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (918, 882, 253, '2017', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (919, 883, 254, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (920, 884, 196, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (921, 885, 255, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (922, 886, 201, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (923, 887, 262, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (924, 888, 253, '2018', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (925, 889, 257, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (926, 890, 258, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (927, 891, 256, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (928, 892, 259, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (929, 893, 260, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (930, 894, 261, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (931, 895, 263, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (932, 896, 106, 'A', '2020-09-03 14:18:06', '2020-09-03 14:18:06', 2, 2, 5);
INSERT INTO public.kelas_mata_kuliah VALUES (933, 897, 320, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (934, 898, 320, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (935, 899, 320, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (936, 900, 320, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (937, 901, 320, 'E', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (938, 902, 321, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (939, 903, 321, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (940, 904, 321, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (941, 905, 321, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (942, 906, 322, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (943, 907, 322, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (944, 908, 322, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (945, 909, 322, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (946, 910, 323, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (947, 911, 323, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (948, 912, 323, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (949, 913, 323, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (950, 914, 323, 'E', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (951, 915, 323, 'F', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (952, 916, 324, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (953, 917, 324, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (954, 918, 324, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (955, 919, 324, 'E', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (956, 920, 325, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (957, 921, 325, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (958, 922, 325, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (959, 923, 325, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (960, 924, 325, 'E', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (961, 925, 326, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (962, 926, 326, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (963, 927, 326, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (964, 928, 326, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (965, 929, 326, 'E', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (966, 930, 327, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (967, 931, 327, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (968, 932, 327, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (969, 933, 327, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (970, 934, 327, 'E', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (971, 935, 328, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (972, 936, 329, 'A1', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (973, 937, 329, 'B1', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (974, 938, 329, 'C1', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (975, 939, 329, 'D1', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (976, 940, 329, 'E1', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (977, 941, 330, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (978, 942, 330, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (979, 943, 330, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (980, 944, 330, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (981, 945, 331, 'A1', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (982, 946, 331, 'A2', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (983, 947, 331, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (984, 948, 331, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (985, 949, 331, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (986, 950, 332, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (987, 951, 332, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (988, 952, 332, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (989, 953, 332, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (990, 954, 333, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (991, 955, 333, 'B', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (992, 956, 333, 'C', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (993, 957, 333, 'D', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (994, 958, 334, 'A', '2020-09-03 14:18:07', '2020-09-03 14:18:07', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (995, 959, 334, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (996, 960, 334, 'C', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (997, 961, 334, 'D', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (998, 962, 335, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (999, 963, 335, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1000, 964, 324, 'F', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1001, 965, 336, 'AE', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1002, 966, 336, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1003, 967, 336, 'C', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1004, 968, 336, 'D', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1005, 969, 337, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1006, 970, 337, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1007, 886, 201, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1008, 886, 201, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1009, 886, 201, 'C', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1010, 886, 201, 'D', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1011, 971, 338, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1012, 972, 338, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1013, 973, 338, 'C', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1014, 974, 338, 'D', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1015, 975, 338, 'E', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1016, 976, 339, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1017, 977, 339, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1018, 978, 339, 'C', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1019, 979, 340, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1020, 980, 340, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1021, 981, 340, 'C', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1022, 982, 340, 'D', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1023, 983, 341, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1024, 984, 341, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1025, 985, 342, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1026, 986, 342, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1027, 987, 329, 'A2', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1028, 988, 329, 'B2', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1029, 989, 329, 'C2', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1030, 990, 329, 'D2', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1031, 991, 329, 'E2', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1032, 992, 343, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1033, 993, 343, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1034, 994, 343, 'C', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1035, 995, 343, 'D', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1036, 996, 343, 'E', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1037, 997, 344, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1038, 998, 344, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1039, 999, 344, 'C', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1040, 1000, 344, 'D', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1041, 1001, 345, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1042, 1002, 345, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1043, 845, 196, 'A', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1044, 845, 196, 'B', '2020-09-03 14:18:08', '2020-09-03 14:18:08', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1045, 845, 196, 'C', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1046, 845, 196, 'D', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1047, 1003, 324, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1048, 1004, 346, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1049, 1005, 346, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1050, 1006, 346, 'C', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1051, 1007, 346, 'D', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 2, 2, 6);
INSERT INTO public.kelas_mata_kuliah VALUES (1052, 1008, 347, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1053, 1009, 347, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1054, 1010, 347, 'C', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1055, 1011, 348, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1056, 1012, 348, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1057, 1013, 349, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1058, 1014, 349, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1059, 1015, 350, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1060, 1016, 350, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1061, 1017, 350, 'C', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1062, 1018, 351, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1063, 1019, 352, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1064, 1020, 2, 'IslmA', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1065, 1020, 2, 'IslmB', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1066, 1021, 353, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1067, 1022, 354, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1068, 1023, 355, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1069, 1024, 356, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1070, 1025, 356, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1071, 273, 7, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1072, 273, 7, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1073, 273, 7, 'C', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1074, 1026, 357, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1075, 1027, 357, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1076, 1028, 358, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1077, 1029, 358, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1078, 1030, 359, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1079, 1031, 360, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1080, 1032, 360, 'B', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1081, 1033, 361, 'A', '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1082, 1034, 362, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1083, 1035, 363, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 10);
INSERT INTO public.kelas_mata_kuliah VALUES (1084, 1036, 364, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1085, 1037, 365, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1086, 1038, 366, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1087, 1039, 367, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1088, 1040, 368, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1089, 1041, 369, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1090, 1042, 370, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1091, 1043, 371, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1092, 273, 7, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1093, 1044, 372, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1094, 1045, 373, 'B', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1095, 1046, 374, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1096, 1047, 364, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1097, 1048, 375, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1098, 1049, 367, 'B', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1099, 1050, 376, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1100, 1051, 365, 'B', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1101, 1052, 377, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1102, 1053, 378, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1103, 1054, 378, 'B', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1104, 1055, 375, 'B', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1105, 1056, 379, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1106, 1057, 380, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1107, 1058, 381, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1108, 1059, 381, 'B', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1109, 1060, 371, 'B', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1110, 1061, 382, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1111, 1062, 383, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1112, 1063, 2, 'islam', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1113, 1064, 384, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1114, 1065, 385, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1115, 1066, 386, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1116, 1067, 387, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1117, 1068, 388, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1118, 1069, 378, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1119, 1070, 378, 'B', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1120, 1071, 373, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1121, 357, 2, 'budha', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1122, 358, 2, 'hindu', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1123, 359, 2, 'Ktlk', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1124, 360, 2, 'Prtsn', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1125, 1072, 389, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1126, 1073, 390, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1127, 1074, 391, 'B', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1128, 1075, 392, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1129, 1076, 393, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1130, 1077, 394, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1131, 1078, 196, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1132, 1079, 201, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1133, 1080, 395, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1134, 1081, 396, 'A', '2020-09-03 14:18:10', '2020-09-03 14:18:10', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1135, 1082, 397, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1136, 1083, 398, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1137, 1084, 394, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1138, 1085, 399, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1139, 1086, 392, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1140, 1087, 400, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1141, 1088, 401, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1142, 1089, 402, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1143, 1090, 396, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1144, 1091, 403, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1145, 1092, 404, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1146, 1093, 405, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1147, 1094, 406, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1148, 1095, 407, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1149, 1096, 408, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1150, 1097, 397, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1151, 1098, 409, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1152, 1099, 410, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1153, 1100, 411, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1154, 1101, 405, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1155, 1102, 412, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1156, 1103, 413, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1157, 1104, 391, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1158, 1105, 414, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1159, 1106, 415, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1160, 1107, 416, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1161, 1108, 411, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1162, 1109, 408, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1163, 1110, 399, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1164, 1111, 395, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1165, 1112, 417, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1166, 1113, 418, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1167, 1114, 419, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 2, 2, 11);
INSERT INTO public.kelas_mata_kuliah VALUES (1168, 1115, 420, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1169, 1116, 421, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1170, 1117, 422, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1171, 1118, 423, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1172, 1119, 424, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1173, 1120, 425, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1174, 1121, 426, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1175, 1122, 427, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1176, 1123, 7, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1177, 1124, 428, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1178, 1125, 429, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1179, 1126, 430, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1180, 1127, 431, 'A', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1181, 1128, 432, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1182, 1129, 433, 'B', '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1183, 1130, 434, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1184, 1131, 424, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1185, 1132, 435, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1186, 1133, 426, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1187, 1134, 436, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1188, 1135, 427, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1189, 1136, 437, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1190, 1136, 437, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1191, 1137, 438, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1192, 1138, 439, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1193, 1139, 436, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1194, 1140, 432, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1195, 1141, 436, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1196, 1142, 440, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1197, 1143, 429, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1198, 1144, 441, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1199, 1145, 2, 'Islam', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1200, 1146, 439, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1201, 1147, 440, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1202, 1148, 442, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1203, 1149, 440, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1204, 1150, 421, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1205, 1151, 443, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1206, 1152, 428, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1207, 1153, 422, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1208, 1154, 435, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1209, 1155, 420, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1210, 1156, 427, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1211, 1157, 440, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1212, 1158, 444, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1213, 1159, 438, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1214, 1160, 436, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1215, 1161, 431, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1216, 1162, 423, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1217, 1163, 427, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1218, 1164, 425, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1219, 1165, 420, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1220, 1166, 442, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1221, 357, 2, 'Budha', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1222, 358, 2, 'Hindu', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1223, 359, 2, 'Ktlk', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1224, 360, 2, 'Prtsn', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1225, 1167, 420, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1226, 1168, 434, 'B', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1227, 1169, 433, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 12);
INSERT INTO public.kelas_mata_kuliah VALUES (1228, 1170, 445, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1229, 1171, 446, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1230, 1172, 447, 'A', '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1231, 1173, 448, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1232, 1174, 7, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1233, 1175, 449, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1234, 1176, 450, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1235, 1177, 451, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1236, 1178, 452, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1237, 1179, 453, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1238, 1180, 454, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1239, 1181, 455, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1240, 1182, 456, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1241, 1183, 457, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1242, 1184, 458, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1243, 1185, 459, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1244, 1186, 460, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1245, 1187, 461, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1246, 1188, 462, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1247, 1189, 463, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1248, 1190, 464, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1249, 1191, 465, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1250, 1192, 466, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1251, 1193, 467, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1252, 1194, 468, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1253, 1195, 291, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1254, 1196, 2, 'Islam', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1255, 1197, 469, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1256, 1198, 470, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1257, 357, 2, 'Budha', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1258, 358, 2, 'Hindu', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1259, 359, 2, 'Ktlk', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1260, 360, 2, 'Prtsn', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1261, 1199, 471, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1262, 1200, 472, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1263, 1201, 473, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1264, 1202, 474, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1265, 1203, 475, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1266, 1204, 476, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1267, 1205, 477, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1268, 1206, 478, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1269, 1207, 479, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1270, 1208, 480, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1271, 1209, 481, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1272, 1210, 482, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1273, 1211, 483, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1274, 1212, 484, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1275, 1213, 485, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1276, 1214, 486, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1277, 1215, 487, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1278, 1216, 488, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1279, 1217, 489, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1280, 1218, 490, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1281, 1219, 491, 'A', '2020-09-03 14:18:13', '2020-09-03 14:18:13', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1282, 1220, 492, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1283, 1221, 196, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1284, 1222, 297, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1285, 1223, 493, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1286, 1224, 494, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1287, 1225, 495, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1288, 1226, 496, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1289, 1227, 497, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1290, 1228, 201, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1291, 1229, 498, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1292, 1230, 499, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 1, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1293, 1231, 476, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1294, 1232, 474, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1295, 1233, 473, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1296, 1234, 475, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1297, 1235, 493, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1298, 1236, 479, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1299, 1237, 480, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1300, 1238, 477, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1301, 1239, 478, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1302, 1240, 481, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1303, 1241, 482, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1304, 1242, 496, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1305, 1243, 495, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1306, 1244, 486, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1307, 1245, 487, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1308, 1246, 488, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1309, 1247, 489, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1310, 1248, 490, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1311, 1249, 491, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1312, 1250, 492, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1313, 1251, 196, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1314, 1252, 297, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1315, 1253, 494, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1316, 1254, 484, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1317, 1255, 485, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1318, 1256, 499, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1319, 1257, 498, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1320, 1258, 201, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1321, 1259, 497, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 2, 2, 13);
INSERT INTO public.kelas_mata_kuliah VALUES (1322, 1260, 500, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1323, 1261, 501, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1324, 1262, 502, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1325, 1263, 503, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1326, 1264, 504, 'A', '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1327, 1265, 505, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1328, 1266, 506, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1329, 1267, 2, 'Islam', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1330, 1268, 507, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1331, 1269, 508, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1332, 1270, 509, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1333, 1271, 510, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1334, 1272, 511, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1335, 1273, 512, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1336, 1274, 513, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1337, 1275, 514, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1338, 1276, 515, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1339, 1277, 516, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1340, 1278, 297, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1341, 1279, 517, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1342, 1280, 518, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1343, 1281, 519, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1344, 1282, 520, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1345, 1283, 7, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1346, 1284, 521, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1347, 357, 2, 'Budha', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1348, 358, 2, 'Hindu', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1349, 359, 2, 'Ktlk', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1350, 360, 2, 'Prtsn', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1351, 1285, 522, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1352, 1286, 523, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1353, 1287, 196, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1354, 1288, 524, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1355, 1289, 525, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1356, 1290, 526, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1357, 1291, 527, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1358, 1292, 528, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1359, 1293, 291, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1360, 1294, 201, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1361, 1295, 529, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1362, 1296, 530, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1363, 1297, 531, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1364, 1298, 532, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1365, 1299, 533, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1366, 1300, 534, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1367, 1301, 535, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1368, 1302, 536, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1369, 1303, 537, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1370, 1304, 538, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1371, 1305, 539, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1372, 1306, 540, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1373, 1307, 541, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1374, 1308, 542, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1375, 1309, 543, 'A', '2020-09-03 14:18:15', '2020-09-03 14:18:15', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1376, 1310, 544, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1377, 1311, 545, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1378, 1312, 546, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 1, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1379, 1313, 196, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1380, 1314, 524, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1381, 1315, 525, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1382, 1316, 527, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1383, 1317, 528, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1384, 1318, 291, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1385, 1319, 201, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1386, 1320, 529, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1387, 1321, 530, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1388, 1322, 531, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1389, 1323, 532, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1390, 1324, 533, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1391, 1325, 534, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1392, 1326, 535, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1393, 1327, 536, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1394, 1328, 537, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1395, 1329, 526, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1396, 1330, 538, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1397, 1331, 539, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1398, 1332, 545, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1399, 1333, 540, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1400, 1334, 541, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1401, 1335, 542, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1402, 1336, 543, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1403, 1337, 544, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);
INSERT INTO public.kelas_mata_kuliah VALUES (1404, 1338, 546, 'A', '2020-09-03 14:18:16', '2020-09-03 14:18:16', 2, 2, 14);


--
-- Data for Name: mata_kuliah; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.mata_kuliah VALUES (1, 'TEKNOLOGI BAHAN BANGUNAN LAUT', 'TKL-1513', 5, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (2, 'AGAMA', 'MKWU1', 1, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.mata_kuliah VALUES (3, 'PROSES PANTAI', 'TKL-1731', 7, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (4, 'KALKULUS I', 'TK1101', 1, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (5, 'REKLAMASI DAN PENGERUKAN', 'TKL-1734', 7, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (6, 'MEKANIKA REKAYASA I', 'TKS-1313', 3, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (7, 'PANCASILA', 'MKWU2', 1, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.mata_kuliah VALUES (8, 'DASAR-DASAR BANGUNAN APUNG', 'TKL-1531', 5, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (9, 'PENGENALAN TEKNIK KELAUTAN', 'TKL-1337', 3, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (10, 'INFRASTRUKTUR PERTANIAN PASANG SURUT', 'TKL-1735', 7, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (11, 'REKAYASA TRANSPORTASI DASAR', 'TKS-1311', 3, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (12, 'PENGETAHUAN LINGKUNGAN', 'TKL1135', 1, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (13, 'STRUKTUR BETON / BAJA', 'TKS-1515', 5, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (14, 'HIDRODINAMIKA (PIL.)', 'TKL-18381', 7, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (15, 'OSEANOGRAFI FISIK', 'TKL-1336', 3, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (16, 'DASAR-DASAR ELEMEN HINGGA', 'TKS-1537', 5, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (17, 'FISIKA DASAR I', 'TK1102', 1, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (18, 'ANALISIS PROBABILITAS & STATISTIK', 'TKL-1335', 3, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (19, 'BANGUNAN PANTAI (TGS PERANCANGAN)', 'TKL-1733', 7, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (20, 'KONSEP PEMBANGUNAN INFRASTRUKTUR', 'TKS1116', 1, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (21, 'GAMBAR TEKNIK', 'TKS-1314', 3, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (22, 'GEOTEKNIK KELAUTAN', 'TKS-1522', 5, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (23, 'KIMIA DASAR I', 'TK1103', 1, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (24, 'BAHASA INGGRIS', 'UT1104', 1, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', NULL);
INSERT INTO public.mata_kuliah VALUES (25, 'MITIGASI BENCANA (PIL.)', 'TKL-17384', 7, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (26, 'EKONOMI REKAYASA', 'TKS-1556', 5, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (27, 'LINGKUNGAN LAUT', 'TKL-1534', 5, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (28, 'MEKANIKA FLUIDA (T)', 'TKL-1332', 3, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.mata_kuliah VALUES (29, 'MIKROBIOLOGI', 'TKL-3212', 3, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 3);
INSERT INTO public.mata_kuliah VALUES (30, 'PENGELOLAAN LINGKUNGAN DAERAH PESISIR (PIL.)', 'TKL-7701', 7, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 3);
INSERT INTO public.mata_kuliah VALUES (31, 'PLAMBING DAN POMPA', 'TKL-5322', 5, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 3);
INSERT INTO public.mata_kuliah VALUES (32, 'SATUAN OPERASI', 'TKL-3320', 3, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 3);
INSERT INTO public.mata_kuliah VALUES (33, 'SURVEY DAN PERPETAAN', 'TKL-3244', 3, 3, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 3);
INSERT INTO public.mata_kuliah VALUES (34, 'EKONOMI LINGKUNGAN', 'TKL-7713', 7, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 3);
INSERT INTO public.mata_kuliah VALUES (35, 'BIOLOGI LINGKUNGAN', 'TKL-1118', 1, 2, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 3);
INSERT INTO public.mata_kuliah VALUES (36, 'PENGELOLAAN PERSAMPAHAN', 'TKL-5327', 5, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (37, 'SATUAN PROSES', 'TKL-3321', 3, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (38, 'EKOTOKSIKOLOGI', 'TKL-5443', 5, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (39, 'PENGETAHUAN STRUKTUR', 'TKL-3242', 3, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (40, 'FISIKA', 'TKL-1103', 1, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (41, 'KESEHATAN LINGKUNGAN', 'TKL-5433', 5, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (42, 'PRAKTIKUM MIKROBIOLOGI', 'TKL-3218', 3, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (43, 'KIMIA', 'TKL-1111', 1, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (44, 'SOSIOLOGI LINGKUNGAN', 'TKL-5424', 5, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (45, 'MEKANIKA TANAH DAN PONDASI', 'TKL-3241', 3, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (46, 'PENGELOLAAN BUANGAN INDUSTRI', 'TKL-5425', 5, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (47, 'HUKUM LINGKUNGAN', 'TKL-7711', 7, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (48, 'HIDROLIKA', 'TKL-3331', 3, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (49, 'PERENCANAAN BANGUNAN PENGELOLAAN AIR BUANGAN', 'TKL-5423', 5, 3, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (50, 'AMDAL', 'TKL-7431', 7, 3, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (51, 'PENGETAHUAN BAHASA DAN KOMUNIKASI (INGGRIS)', 'UMG-1104', 1, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', NULL);
INSERT INTO public.mata_kuliah VALUES (52, 'REKAYASA LINGKUNGAN UDARA', 'TKL-3220', 3, 3, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (53, 'MANAJEMEN PROYEK', 'TKL-7441', 7, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (54, 'PERENCANAAN BANGUNAN PENGOLAHAN AIR MINUM', 'TKL-5437', 5, 3, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (55, 'MATEMATIKA', 'TKL-1101', 1, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (56, 'PENGANTAR REKAYASA LINGKUNGAN', 'TKL-1104', 1, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (57, 'BIOTEKNOLOGI LINGKUNGAN (PIL.)', 'TKL-7703', 7, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (58, 'TECHNOPRENEURSHIP (PIL.)', 'TKL-7702', 7, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (59, 'PEMB. BERKELANJUTAN DAN KEARIFAN LOKAL (PIL.)', 'TKL-7710', 7, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (60, 'TEKNOLOGI BERSIH DAN MINIMASI LIMBAH (PIL.)', 'TKL-7705', 7, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (61, 'PRAKTIKUM MEKANIKA FLUIDA', 'TKL-3216', 3, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (62, 'GIS LINGKUNGAN (PIL.)', 'TKL-7717', 7, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 3);
INSERT INTO public.mata_kuliah VALUES (63, 'K3 DAN LINGKUNGAN TAMBANG', 'TPB-520', 5, 3, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 4);
INSERT INTO public.mata_kuliah VALUES (64, 'GEOSTATISTIKA', 'TPB-529', 5, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 4);
INSERT INTO public.mata_kuliah VALUES (65, 'MATEMATIKA I', 'TPB-102', 1, 3, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 4);
INSERT INTO public.mata_kuliah VALUES (66, 'METODE NUMERIK', 'TPB-314', 3, 2, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 4);
INSERT INTO public.mata_kuliah VALUES (67, 'PENGEMBANGAN WILAYAH (PIL.)', 'TPB-748', 7, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (68, 'GAMBAR TEKNIK', 'TPB-319', 3, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (69, 'METALURGI (PIL.)', 'TPB-747', 7, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (70, 'ILMU UKUR TAMBANG', 'TPB-523', 5, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (71, 'GEOLOGI DASAR', 'TPB-106', 1, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (72, 'BAHAN PELEDAK DAN TEKNIK PELEDAKAN (P)', 'TPB-522', 5, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (73, 'AMDAL PERTAMBANGAN (PIL.)', 'TPB-746', 7, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (74, 'TEKNIK TENAGA LISTRIK DAN PENGGERAK MULA', 'TPB-318', 3, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (75, 'TEKNIK TEROWONGAN DAN PENYANGGAAN', 'TPB-738', 7, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (76, 'GEOLOGI STRUKTUR (P)', 'TPB-315', 3, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (77, 'ANALISIS INVESTASI TAMBANG', 'TPB-737', 7, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (78, 'MEKANIKA TEKNIK', 'TPB-313', 3, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (79, 'FISIKA (P) I', 'TPB-103', 1, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (80, 'METODA PERHITUNGAN CADANGAN', 'TPB-521', 5, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (81, 'TATA TULIS KARYA ILMIAH', 'TPB-105', 1, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (82, 'HUKUM PERTAMBANGAN DAN KETENAGAKERJAAN', 'TPB-526', 5, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (83, 'MEKANIKA TANAH (P)', 'TPB-317', 3, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (84, 'TEKNOLOGI BATUBARA', 'TPB-734', 7, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (85, 'GENESA BAHAN GALIAN', 'TPB-316', 3, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (86, 'SISTEM PENYALIRAN TAMBANG', 'TPB-736', 7, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (87, 'KIMIA (P) I', 'TPB-104', 1, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (88, 'GEOFISIKA TAMBANG', 'TPB-524', 5, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (89, 'STATISTIK DASAR', 'TPB-101', 1, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (90, 'SIMULASI DAN KOMPUTASI TAMBANG', 'TPB-525', 5, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (91, 'MEKANIKA FLUIDA', 'TPB-320', 3, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 4);
INSERT INTO public.mata_kuliah VALUES (92, 'MATEMATIKA', 'TP-2104', 1, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (93, 'PERENCANAAN TRANSPORTASI', 'TP-3104', 5, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (94, 'TEKNIK PRESENTASI DAN KOMUNIKASI', 'TP-2107', 1, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (95, 'PENGELOLAAN KAWASAN LAHAN BASAH', 'TP-3122', 5, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (96, 'PEMBANGUNAN BERBASIS MASYARAKAT', 'TP-3210', 7, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (97, 'EKONOMI PEMBANGUNAN', 'TP-3103', 5, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (98, 'TEORI PERENCANAAN TAPAK', 'TP-3128', 3, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (99, 'SISTEM INFORMASI PERENCANAAN', 'TP-3120', 5, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (100, 'PENGANTAR KEPARIWISATAAN (PIL.)', 'TP-3136', 7, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (101, 'PERENCANAAN KOTA', 'TP-3117', 3, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (102, 'PENGANTAR PERENCANAAN WILAYAH DAN KOTA', 'TP-3111', 1, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (103, 'KEWIRAUSAHAAN', 'TP-4202', 8, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (104, 'STUDIO PERENCANAAN KOTA', 'TP-3121', 5, 4, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (105, 'TATA GUNA DAN PENGEMBANGAN LAHAN', 'TP-3125', 3, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (106, 'TATA TULIS KARYA ILMIAH DAN SEMINAR', 'TP-4103', 7, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (107, 'PERENCANAAN WILAYAH', 'TP-3218', 3, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (108, 'GEOGRAFI LINGKUNGAN', 'TP-2103', 1, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (109, 'DAS DAN PENGELOLAAN SUNGAI', 'TP-3114', 3, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (110, 'PERENCANAAN PERDESAAN', 'TP-3116', 5, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (111, 'PROSES PERENCANAAN', 'TP-3119', 3, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (112, 'PENGELOLAAN KAWASAN PESISIR', 'TP-3129', 7, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (113, 'BAHASA INGGRIS', 'UMG-103', 1, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', NULL);
INSERT INTO public.mata_kuliah VALUES (114, 'HUKUM DAN KEBIJAKAN', 'TP-4101', 7, 3, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (115, 'MASALAH PEMBANGUNAN WILAYAH DAN KOTA (PIL.)', 'TP-3138', 7, 2, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 5);
INSERT INTO public.mata_kuliah VALUES (116, 'TEKNIK EVALUASI PERENCANAAN', 'TP-3126', 5, 3, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 5);
INSERT INTO public.mata_kuliah VALUES (117, 'PEREMAJAAN KOTA DAN PERENCANAAN KOTA (PIL.)', 'TP-3137', 7, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 5);
INSERT INTO public.mata_kuliah VALUES (118, 'STRUKTUR BETON BERTULANG I (T)', 'TKS-315', 5, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (119, 'PERANCANGAN PERKERASAN JALAN (PR)', 'TKS-351', 5, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (120, 'REKAYASA HIDROLOGI (T)', 'TKS-223', 3, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (121, 'PENGELOLAAN ALAT BERAT', 'TKS-433', 7, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (122, 'SISTEM PEMBIAYAAN PROYEK (PL)', 'TKS-437', 7, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (123, 'MEKANIKA BAHAN', 'TKS-211', 3, 3, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (124, 'REKAYASA PONDASI III (PL)', 'TKS-443', 7, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (125, 'MEKANIKA TANAH I (PR)', 'TKS-241', 3, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (126, 'PENGEMBANGAN SUMBER DAYA AIR', 'TKS-421', 7, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (127, 'DASAR-DASAR REKAYASA TRANSPORTASI', 'TKS-253', 3, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (128, 'PERENCANAAN DAN PENGENDALIAN PROYEK (PR)', 'TKS-431', 7, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (129, 'KIMIA DASAR', 'TKS-103', 1, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (130, 'IRIGASI DAN BANGUNAN AIR I (T)', 'TKS-321', 5, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (131, 'FISIKA DASAR (PR)', 'TKS-101', 1, 3, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (132, 'STRUKTUR BAJA I (T)', 'TKS-311', 5, 2, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 6);
INSERT INTO public.mata_kuliah VALUES (133, 'BAHASA PEMROGRAMAN (PR)', 'TKS-163', 1, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (134, 'REKAYASA PONDASI I (T)', 'TKS-341', 5, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (135, 'STATIKA I', 'TKS-161', 1, 3, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (136, 'SURVEY DAN PEMETAAN II (PR)', 'TKS-251', 3, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (137, 'SISTEM TRANSPORTASI MASAL (PL)', 'TKS-455', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (138, 'STRUKTUR KAYU II (PL)', 'TKS-411', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (139, 'PENELITIAN OPERASIONAL II (PL)', 'TKS-435', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (140, 'STATISTIK DAN PROBABILITAS', 'TKS-261', 3, 3, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (141, 'MENGGAMBAR REKAYASA & STRUK. BANGUNAN I (T)', 'TKS-165', 1, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (142, 'ANALISIS STRUKTUR II', 'TKS-313', 5, 3, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (143, 'MEKANIKA FLUIDA (PR)', 'TKS-221', 3, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (144, 'REKAYASA LAPANGAN TERBANG (T)', 'TKS-451', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (145, 'MANAJEMEN KONSTRUKSI', 'TKS-331', 5, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (146, 'REKAYASA GEMPA (PL)', 'TKS-415', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (147, 'PENGEMBANGAN LAHAN BASAH (PL)', 'TKS-425', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (148, 'MATEMATIKA III', 'TKS-201', 3, 3, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (149, 'REKAYASA PANTAI (PL)', 'TKS-427', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (150, 'MATEMATIKA I', 'TK-101', 1, 3, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (151, 'ANALISIS NUMERIK DAN PEMROGRAMAN', 'TKS-361', 5, 3, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (152, 'STRUKTUR BAJA III (PL)', 'TKS-413', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (153, 'VIBRASI DAN DINAMIKA TANAH (PL)', 'TKS-445', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (154, 'ANALISIS DAMPAK LALU LINTAS (PL)', 'TKS-457', 7, 2, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 6);
INSERT INTO public.mata_kuliah VALUES (155, 'MANAJEMEN KAWASAN PESISIR (PIL.)', 'TKL-18584', 7, 3, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 2);
INSERT INTO public.mata_kuliah VALUES (156, 'MEKANIKA FLUIDA', 'TKL-4211', 4, 3, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 3);
INSERT INTO public.mata_kuliah VALUES (157, 'ANALISIS BEBAN PENCEMARAN AIR (PIL.)', 'TKL-8803', 8, 2, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 3);
INSERT INTO public.mata_kuliah VALUES (158, 'MEKANIKA REKAYASA', 'TKL-2119', 2, 2, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 3);
INSERT INTO public.mata_kuliah VALUES (159, 'MANAJEMEN DAN PENGEMBANGAN LAHAN (PIL.)', 'TP-3139', 7, 2, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 5);
INSERT INTO public.mata_kuliah VALUES (160, 'METODE NUMERIK', 'TKS-3361', 5, 2, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 6);
INSERT INTO public.mata_kuliah VALUES (161, 'STATISTIK UNTUK TEKNIK SIPIL', 'TKS-1261', 1, 2, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 6);
INSERT INTO public.mata_kuliah VALUES (162, 'REKAYASA LINGKUNGAN', 'TKS-3105', 5, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (163, 'MEKANIKA TANAH I (PR)', 'TKS-2241', 3, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (164, 'ESTIMASI BIAYA KONSTRUSI', 'TKS-4437', 7, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (165, 'BETON PRATEGANG (PL)', 'TKS-4418', 7, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (166, 'PERANCANGAN GEOMETRIK JALAN RAYA DAN JALAN REL (T)', 'TKS-2250', 3, 3, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (167, 'REKAYASA DAN KESELAMATAN LALU LINTAS', 'TKS-2252', 3, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (168, 'VIBRASI DAN DINAMIKA TANAH (PL)', 'TKS-4445', 7, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (169, 'MATEMATIKA REKAYASA I', 'TKS-1101', 1, 3, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (170, 'DINAMIKA STRUKTUR DAN GEMPA', 'TKS-3314', 5, 3, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (171, 'MANAJEMEN PROYEK KONSTRUKSI', 'TKS-2331', 3, 3, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (172, 'PERANCANGAN IRIGASI DAN BANGUNAN AIR (T)', 'TKS-4321', 7, 3, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (173, 'REKAYASA LAHAN BASAH (PL)', 'TKS-4425', 7, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (174, 'MEKANIKA FLUIDA (PR)', 'TKS-1221', 1, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (175, 'EKONOMI REKAYASA DAN STUDI KELAYAKAN PROYEK', 'TKS-3230', 5, 2, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 6);
INSERT INTO public.mata_kuliah VALUES (176, 'STRUKTUR STATIS TERTENTU', 'TKS-1161', 1, 3, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (177, 'PERANCANGAN FONDASI (T)', 'TKS-3341', 5, 3, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (178, 'GEOLOGI TEKNIK DAN MEKANIKA BATUAN', 'TKS-4140', 7, 2, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (179, 'MEKANIKA BAHAN', 'TKS-2211', 3, 3, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (180, 'PEMODELAN TRANSPORTASI (PL)', 'TKS-4452', 7, 2, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (181, 'MENGGAMBAR STRUKTUR BANGUNAN SIPIL (T)', 'TKS-1165', 1, 3, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (182, 'PERANCANGAN PERKERASAN JALAN DAN LANDAS PACU (PR)', 'TKS-3351', 5, 3, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (183, 'PEMROGRAMAN KOMPUTER', 'TKS-2163', 3, 2, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (184, 'STRUKTUR STATIS TAK TENTU', 'TKS-2212', 3, 3, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (185, 'OPERASIONAL PELABUHAN (PL)', 'TKS-4453', 7, 2, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (186, 'TEKNOLOGI BAHAN KONSTRUKSI (PR)', 'TKS-1164', 1, 3, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (187, 'STRUKTUR BANGUNAN BETON (T)', 'TKS-3316', 5, 3, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (188, 'MATEMATIKA REKAYASA III', 'TKS-2201', 3, 2, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (189, 'REKAYASA JEMBATAN (T)', 'TKS-4413', 7, 3, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (190, 'MANAJEMEN RESIKO KONSTRUKSI (PL)', 'TKS-4439', 7, 2, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 6);
INSERT INTO public.mata_kuliah VALUES (191, 'FISIKA DASAR II', 'TK-1202', 2, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (192, 'MANAJEMEN KONSTRUKSI BANGUNAN LAUT', 'TKL-1832', 8, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (193, 'SISTEM ANALISIS MANAJEMEN', 'TKL-1437', 4, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (194, 'TECHNOPRENEUR', 'UT-1804', 8, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.mata_kuliah VALUES (195, 'ANALISIS REKAYASA DASAR II', 'TKS-1411', 4, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (196, 'BAHASA INDONESIA', 'MKWU4', 2, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.mata_kuliah VALUES (197, 'METODE EKSPERIMEN LABORATORIUM & LAPANGAN', 'TKL-1635', 6, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (198, 'PENCEMARAN LAUT', 'TKL-1235', 2, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (199, 'DINAMIKA MUARA (ESTUARY)', 'TKL-1631', 6, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (200, 'HIDROGRAFI DAN BATHIMETRI', 'TKL-1435', 4, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (201, 'KEWARGANEGARAAN', 'MKWU3', 2, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', NULL);
INSERT INTO public.mata_kuliah VALUES (202, 'MEKANIKA REKAYASA II', 'TKD-1413', 4, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (203, 'TEKNOLOGI PIPA BAWAH LAUT (PIL.)', 'TKL-18372', 8, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (204, 'INFRASTRUKTUR BUDIDAYA PERIKANAN PANTAI', 'TKL-18384', 8, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (205, 'KALKULUS II', 'TK-1201', 2, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (206, 'GEOTEKNIK KELAUTAN II', 'TKS-1622', 6, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (207, 'KOMPUTER DAN PEMROGRAMAN (PENG.BHS PRGRAM)', 'TK-1207', 2, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (208, 'KONVERSI ENERGI / ENERGI TERBARUKAN', 'TKL-1636', 6, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (209, 'HIDROLOGI DAN HIDROLIKA (PRAKTIKUM)', 'TKS-1436', 4, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (210, 'PERANCANGAN PRASARANA PELABUHAN (T)', 'TKL-1633', 6, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (211, 'MEKANIKA GELOMBANG AIR (PRAKTIKUM)', 'TKL-1432', 4, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (212, 'KONSEP TEKNOLOGI', 'TKL-1206', 2, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (213, 'DINAMIKA STRUKTUR (VATIC)', 'TKL-1614', 6, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (214, 'ANALISA NUMERIK', 'TKL-1434', 4, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 2);
INSERT INTO public.mata_kuliah VALUES (215, 'PRAKTIKUM FISIKA', 'TKL-2112', 2, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (216, 'KIMIA LINGKUNGAN', 'TKL-2113', 2, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (217, 'STATISTIKA LINGKUNGAN', 'TKL-4218', 4, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (218, 'HIDROLOGI LINGKUNGAN', 'TKL-4213', 4, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (219, 'KAPITA SELEKTA AIR LIMBAH (PIL.)', 'TKL-7707', 7, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (220, 'KONSERVASI LINGKUNGAN', 'TKL-4212', 4, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (221, 'PENGELOLAAN LIMBAH B3', 'TKL-6313', 6, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (222, 'FISIKA LINGKUNGAN', 'TKL-2115', 2, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (223, 'KESELAMATAN DAN KESEHATAN KERJA (K3)', 'TKL-6311', 6, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (224, 'KAPITA SELEKTA AIR BERSIH (PIL.)', 'TKL-7706', 7, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (225, 'PENCEMARAN UDARA DAN PEMANTAUAN KUALITAS UDARA', 'TKL-6312', 6, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (226, 'MATEMATIKA REKAYASA', 'TKL-2111', 2, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (227, 'SISTEM PENYEDIAAN AIR MINUM', 'TKL-4214', 4, 3, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (228, 'ENERGI BARU TERBARUKAN BERKELANJUTAN', 'TKL-8217', 8, 2, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 3);
INSERT INTO public.mata_kuliah VALUES (229, 'KLIMATOLOGI', 'TKL-2117', 2, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (230, 'PENELITIAN LINGKUNGAN', 'TKL-6314', 6, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (231, 'LABORATORIUM LINGKUNGAN', 'TKL-4215', 4, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (232, 'REMEDIASI (PIL.)', 'TKL-8802', 8, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (233, 'PENYALURAN AIR BUANGAN DAN DRAINASE', 'TKL-4216', 4, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (234, 'PERENCANAAN TPA SAMPAH', 'TKL-6315', 6, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (235, 'PENCEMARAN TANAH DAN AIR TANAH (PIL.)', 'TKL-7709', 8, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (236, 'PENGELOLAAN KUALITAS LINGKUNGAN', 'TKL-2114', 2, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (237, 'REKAYASA LINGKUNGAN BERBASIS MASYARAKAT (T)', 'TKL-6316', 6, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (238, 'MENGGAMBAR TEKNIK', 'TKL-2118', 2, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (239, 'RESTORASI GAMBUT DAN LAHAN BASAH (PIL.)', 'TKL-8801', 8, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (240, 'PERENCANAAN WILAYAH & TATA RUANG', 'TKL-4217', 4, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (241, 'PRAKTIKUM KIMIA', 'TKL-2116', 2, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 3);
INSERT INTO public.mata_kuliah VALUES (242, 'EKOLOGI DAN SUMBER DAYA ALAM', 'TP-2202', 2, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (243, 'PERANCANGAN KOTA', 'TP-3201', 4, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (244, 'PERUBAHAN IKLIM DAN KEBENCANAAN DALAM PERENCANAAN', 'TP-3234', 6, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (245, 'PENGELOLAAN SUMBER DAYA AIR', 'TP-3233', 4, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (246, 'STUDIO PERENCANAAN WILAYAH DAN PERDESAAN', 'TP-3224', 6, 4, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (247, 'STATISTIK (P)', 'TP-2206', 2, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (248, 'MANAJEMEN INFRASTRUKTUR WILAYAH DAN KOTA (PIL.)', 'TP-3243', 8, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (249, 'INFRASTRUKTUR WILAYAH, KOTA, DAN DESA', 'TP-3205', 2, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (250, 'MANAJEMEN DAN ADMINISTRASI PEMBANGUNAN', 'TP-3235', 8, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (251, 'STUDIO PERENCANAAN TAPAK', 'TP-3223', 4, 4, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (252, 'PERUMAHAN DAN PEMUKIMAN', 'TP-3213', 4, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (253, 'PEMBIAYAAN PEMBANGUNAN', 'TP-3232', 6, 2, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (254, 'TEORI PERENCANAAN', 'TP-3227', 2, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (255, 'METODOLOGI PENELITIAN', 'TP-3209', 6, 3, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 5);
INSERT INTO public.mata_kuliah VALUES (256, 'EKONOMI WILAYAH DAN KOTA', 'TP-3203', 2, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 5);
INSERT INTO public.mata_kuliah VALUES (257, 'DASAR-DASAR GIS', 'TP-3231', 2, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 5);
INSERT INTO public.mata_kuliah VALUES (258, 'PERENCANAAN DESA TERPADU (PIL.)', 'TP-3242', 8, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 5);
INSERT INTO public.mata_kuliah VALUES (259, 'ANALISIS SOSIAL DAN KEPENDUDUKAN', 'TP-2201', 4, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 5);
INSERT INTO public.mata_kuliah VALUES (260, 'ANALISIS LOKASI DAN POLA KERUANGAN', 'TP-3230', 2, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 5);
INSERT INTO public.mata_kuliah VALUES (261, 'PERENCANAAN KAWASAN PERBATASAN (PIL.)', 'TP-3240', 8, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 5);
INSERT INTO public.mata_kuliah VALUES (262, 'METODE ANALISIS PERENCANAAN', 'TP-3208', 4, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 5);
INSERT INTO public.mata_kuliah VALUES (263, 'PERENCANAAN KAWASAN TEPIAN AIR (PIL.)', 'TP-3241', 8, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 5);
INSERT INTO public.mata_kuliah VALUES (264, 'PERANCANGAN GEOMETRIK JALAN  (T)', 'TKS-250', 4, 2, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (265, 'MEKANIKA TANAH III (PL)', 'TKS-442', 8, 2, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (266, 'ANALISIS STRUKTUR I', 'TKS-212', 4, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (267, 'REKAYASA LALU LINTAS', 'TKS-252', 4, 2, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (268, 'STRUKTUR BETON BERTULANG II (T)', 'TKS-316', 6, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (269, 'SURVEY DAN PEMETAAN I (PR)', 'TKS-150', 2, 2, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (270, 'REKAYASA PONDASI II (T)', 'TKS-342', 6, 2, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (271, 'SISTEM ADMINISTRASI PROYEK (T)', 'TKS-332', 6, 2, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (272, 'STRUKTUR BETON BERTULANG III (PL)', 'TKS-418', 8, 2, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (273, 'STATIKA II', 'TKS-162', 2, 3, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 6);
INSERT INTO public.mata_kuliah VALUES (274, 'REKAYASA BENDUNGAN (PL)', 'TKS-422', 8, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (275, 'STUDI KELAYAKAN PROYEK (PL)', 'TKS-434', 8, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (276, 'MATEMATIKA IV', 'TKS-202', 4, 3, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (277, 'STRUKTUR KAYU I (T)', 'TKS-210', 4, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (278, 'EKONOMI REKAYASA', 'TKS-230', 4, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (279, 'ANALISIS EKONOMI TRANSPORTASI (PL)', 'TKS-456', 8, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (280, 'MEKANIKA TANAH II (PR)', 'TKS-242', 4, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (281, 'ANALISIS STRUKTUR III (PL)', 'TKS-416', 8, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (282, 'DRAINASE (PL)', 'TKS-424', 8, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (283, 'PERENCANAAN & PENGENDALIAN PROYEK LANJUTAN (PL)', 'TKS-436', 8, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (284, 'TEKNOLOGI BAHAN KONSTRUKSI (PR)', 'TKS-164', 2, 3, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (285, 'STRUKTUR BAJA II (T)', 'TKS-312', 6, 3, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (286, 'GEOLOGI TEKNIK', 'TKS-140', 2, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (287, 'IRIGASI DAN BANGUNAN AIR II (T)', 'TKS-322', 6, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (288, 'MENGGAMBAR REKAYASA & STRUK. BANGUNAN II (T)', 'TKS-166', 2, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (289, 'PENELITIAN OPERASIONAL I', 'TKS-334', 6, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (290, 'DINAMIKA STRUKTUR', 'TKS-314', 6, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (291, 'ILMU KEALAMAN DASAR', 'UMG-105', 2, 3, '2020-09-03 14:18:03', '2020-09-03 14:18:03', NULL);
INSERT INTO public.mata_kuliah VALUES (292, 'HIDROLIKA (PR)', 'TKS-220', 4, 3, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (293, 'MEKANIKA BATUAN (PL)', 'TKS-444', 8, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (294, 'PERENCANAAN & ANALISIS SISTEM TRANSPORTASI (PL)', 'TKS-452', 8, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (295, 'REKAYASA PELABUHAN (T)', 'TKS-450', 8, 2, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 6);
INSERT INTO public.mata_kuliah VALUES (296, 'MATEMATIKA II', 'TKS-102', 2, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 6);
INSERT INTO public.mata_kuliah VALUES (297, 'BAHASA INGGRIS', 'UMG-106', 6, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', NULL);
INSERT INTO public.mata_kuliah VALUES (298, 'KEWIRAUSAHAAN', 'TK-302', 6, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 6);
INSERT INTO public.mata_kuliah VALUES (299, 'TAMBANG TERBUKA', 'TPB-629', 6, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (300, 'HIDROGEOLOGI (PIL.)', 'TPB-642', 6, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (301, 'TEKNIK EKSPLORASI', 'TPB-421', 4, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (302, 'EKONOMI MINERAL', 'TPB-628', 6, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (303, 'FISIKA II', 'TPB-207', 2, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (304, 'GEOTEKNIK TAMBANG (PIL)', 'TPB-643', 6, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (305, 'ILMU LINGKUNGAN', 'TPB-423', 4, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (306, 'PENGOLAHAN DAN BAHAN GALIAN (P)', 'TPB-422', 4, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (307, 'PERPETAAN (P)', 'TPB-427', 4, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (308, 'MEKANIKA BATUAN (P)', 'TPB-425', 4, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (309, 'PENGANTAR TEKNOLOGI MINERAL', 'TPB-211', 2, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (310, 'VENTILASI TAMBANG', 'TPB-631', 6, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (311, 'MINERALOGI & PETROLOGI (P)', 'TPB-209', 2, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (312, 'TAMBANG BAWAH TANAH', 'TPB-630', 6, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (313, 'KIMIA II', 'TPB-210', 2, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (314, 'KEWIRAUSAHAAN', 'TPB-627', 6, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (315, 'REKLAMASI DAN PENUTUPAN TAMBANG (PIL.)', 'TPB-644', 6, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (316, 'MATEMATIKA II', 'TPB-208', 2, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (317, 'MANAJEMEN TAMBANG', 'TPB-424', 4, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (318, 'ENERGI TERBARUKAN (PIL)', 'TPB-645', 6, 2, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (319, 'PERPINDAHAN TANAH MEKANIS', 'TPB-426', 4, 3, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 4);
INSERT INTO public.mata_kuliah VALUES (320, 'ELEMEN STRUKTUR BAJA', 'TKS-2311', 4, 2, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (321, 'PERENCANAAN PELABUHAN (T)', 'TKS-2450', 4, 3, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (322, 'MEKANIKA TANAH II (PR)', 'TKS-2242', 4, 2, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (323, 'HIDROLOGI (T)', 'TKS-1223', 2, 3, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (324, 'HIDROLIKA (PR)', 'TKS-1220', 2, 2, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (325, 'REKAYASA TERMINAL DAN BANDAR UDARA', 'TKS-3451', 6, 2, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (326, 'RANGKA BATANG', 'TKS-1162', 2, 3, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (327, 'ANALISIS STABILITAS DAN KONSTRUKSI P. TANAH (T)', 'TKS-3342', 6, 3, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (328, 'METODE ELEMEN HINGGA (PL)', 'TKS-4416', 8, 2, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (329, 'PERENCANAAN DAN PELAKSANAAN PROYEK KONSTRUKSI (PR)', 'TKS-2431', 4, 3, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (330, 'BAHASA INGGRIS', 'TKS-3106', 6, 2, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (331, 'ANALISIS STRUKTUR METODE MATRIKS', 'TKS-2313', 4, 3, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (332, 'ELEMEN DAN STRUKTUR BANGUNAN KAYU (T)', 'TKS-2210', 4, 3, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (333, 'SURVEI DAN PEMETAAN (PR)', 'TKS-1150', 2, 3, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (334, 'METODE PELAKSANAAN DAN PERALATAN KONSTRUKSI', 'TKS-3433', 6, 2, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 6);
INSERT INTO public.mata_kuliah VALUES (335, 'STABILISASI DAN PERKUATAN TANAH (PL)', 'TKS-4447', 8, 2, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (336, 'DRAINASE PERKOTAAN', 'TKS-3424', 6, 2, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (337, 'SISTEM SARPRAS DAN OPERASI KA (PL)', 'TKS-4458', 8, 2, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (338, 'DASAR-DASAR REKAYASA TRANSPORTASI', 'TKS-1253', 2, 2, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (339, 'KEWIRAUSAHAAN TEKNIK SIPIL', 'TKS-3302', 6, 2, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (340, 'ELEMEN STRUKTUR BETON', 'TKS-2315', 4, 2, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (341, 'ASPEK HUKUM KONSTRUKSI DAN ETIKA PROFESI (PL)', 'TKS-4432', 8, 2, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (342, 'REKAYASA SUNGAI DAN MUARA (PL)', 'TKS-4422', 8, 2, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (343, 'MATEMATIKA REKAYASA II', 'TKS-1102', 2, 3, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (344, 'STRUKTUR BANGUNAN BAJA (T)', 'TKS-3312', 6, 3, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (345, 'TRANSPORTASI LOGISTIK PELABUHAN (PL)', 'TKS-4459', 8, 2, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 6);
INSERT INTO public.mata_kuliah VALUES (346, 'PENGEMBANGAN SUMBER DAYA AIR', 'TKS-4421', 8, 2, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 6);
INSERT INTO public.mata_kuliah VALUES (347, 'FISIKA DASAR I', 'TKE-103', 1, 3, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (348, 'TEKNIK TEGANGAN TINGGI', 'TTL-331', 5, 3, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (349, 'PENGANTAR SISTEM CERDAS', 'TKK-323', 5, 3, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (350, 'DASAR ELEKTRONIKA', 'TKE-215', 3, 2, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (351, 'TEKNOLOGI INFORMASI', 'TET-421', 7, 2, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (352, 'PERALATAN TEGANGAN TINGGI', 'TTL-433', 7, 2, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (353, 'ANTENA DAN PROPAGASI', 'TET-433', 7, 3, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (354, 'ANALISA SISTEM TENAGA (T)', 'TTL-431', 7, 3, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (355, 'ROBOTIKA', 'TEK-437', 7, 3, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (356, 'KONSEP TEKNOLOGI', 'TKE-201', 3, 2, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (357, 'MEDAN ELEKTROMAGNETIK II', 'TTL-321', 5, 2, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (358, 'ELEKTRONIKA I', 'TKK-331', 5, 2, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (359, 'TEKNOLOGI GSM', 'TET-431', 7, 2, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (360, 'MATEMATIKA TEKNIK I', 'TKE-205', 3, 3, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (361, 'SISTEM KENDALI DIGITAL', 'TEK-433', 7, 3, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 10);
INSERT INTO public.mata_kuliah VALUES (362, 'KENDALI LOGIKA FUZZY (P)', 'TEK-452', 8, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 10);
INSERT INTO public.mata_kuliah VALUES (363, 'ELEKTRONIKA TELEKOMUNIKASI', 'TEL-430', 8, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 10);
INSERT INTO public.mata_kuliah VALUES (364, 'FISIKA DASAR', 'TIN-1153', 1, 4, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (365, 'PENELITIAN OPERASIONAL 1', 'TIN-2273', 3, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (366, 'ANALISIS DAN PERANCANGAN SISTEM INFORMASI', 'TIN-3350', 5, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (367, 'PENGANTAR TEKNIK INDUSTRI', 'TIN-1155', 1, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (368, 'PROSES MANUFAKTUR', 'TIN-2251', 3, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (369, 'SISTEM MANUSIA MESIN (P)', 'TIN-4460', 8, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (370, 'MANAJEMEN INOVASI DAN KEWIRAUSAHAAN', 'TIN-4440', 7, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (371, 'MENGGAMBAR TEKNIK', 'TIN-1150', 1, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (372, 'SISTEM LINGKUNGAN INDUSTRI', 'TIN-3380', 5, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (373, 'PENGANTAR MANAJEMEN DAN BISNIS', 'TIN-2240', 3, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (374, 'SISTEM MANUFAKTUR FLEKSIBEL (P)', 'TIN-4482', 8, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (375, 'STATISTIKA INDUSTRI 2', 'TIN-2271', 3, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (376, 'SIMULASI SISTEM INDUSTRI', 'TIN-3352', 5, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (377, 'SISTEM PRODUKSI', 'TIN-3381', 5, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (378, 'KALKULUS DASAR', 'TIN-1170', 1, 4, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (379, 'PERANCANGAN EKSPERIMEN (P)', 'TIN-4470', 7, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (380, 'KESEHATAN DAN KESELAMATAN KERJA', 'TIN-3360', 5, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (381, 'PEMROGRAMAN DAN DASAR KOMPUTER', 'TIN-1151', 1, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (382, 'ELEMEN MESIN', 'TIN-2250', 3, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (383, 'MANAJEMEN PROYEK', 'TIN-3341', 5, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (384, 'SISTEM DISTRIBUSI DAN TRANSPORTASI (P)', 'TIN-4433', 7, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (385, 'PERANCANGAN SISTEM KERJA DAN ERGONOMI', 'TIN-2260', 3, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (386, 'OTOMASI SISTEM PRODUKSI', 'TIN-4480', 7, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (387, 'ORGANISASI DAN MANAJEMEN PERUSAHAAN INDUSTRI', 'TIN-3340', 5, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (388, 'MANAJEMEN PEMASARAN (P)', 'TIN-4442', 7, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (389, 'SISTEM DINAMIS (P)', 'TIN-4471', 8, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (390, 'MATEMATIKA OPTIMISASI', 'TIN-2270', 3, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (391, 'STATISTIKA INDUSTRI 1', 'TIN-1172', 2, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (392, 'PENGENDALIAN DAN PENJAMINAN MUTU', 'TIN-3354', 4, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (393, 'SISTEM MANUFAKTUR TERINTEGRASI (P)', 'TIN-4484', 8, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (394, 'EKONOMI TEKNIK', 'TIN-3355', 6, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (395, 'PEMODELAN SISTEM', 'TIN-3373', 6, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (396, 'MATERIAL TEKNIK', 'TIN-1158', 2, 2, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (397, 'PERENCANAAN DAN PENGENDALIAN PRODUKSI', 'TIN-2280', 4, 3, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 11);
INSERT INTO public.mata_kuliah VALUES (398, 'MANAJEMEN STRATEGI (P)', 'TIN-4441', 7, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (399, 'FISIOLOGI DAN PENGUKURAN KERJA', 'TIN-1160', 2, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (400, 'REKAYASA NILAI (P)', 'TIN-4454', 7, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (401, 'PERANCANGAN DAN PENGEMBANGAN PRODUK', 'TIN-2282', 4, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (402, 'ANALISIS DAN PERANCANGAN PERUSAHAAN', 'TIN-3383', 6, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (403, 'MANAJEMEN INDUSTRI KECIL DAN MENENGAH (P)', 'TIN-4444', 8, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (404, 'ALJABAR LINIER', 'TIN-1171', 2, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (405, 'PENELITIAN OPERASIONAL 2', 'TIN-2274', 4, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (406, 'METODOLOGI PENELITIAN', 'TIN-3342', 6, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (407, 'KIMIA INDUSTRI', 'TIN-1156', 2, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (408, 'PERANCANGAN TATA LETAK FASILITAS', 'TIN-3384', 6, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (409, 'MANAJEMEN RANTAI PASOK', 'TIN-3382', 6, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (410, 'MANAJEMEN KEUANGAN (P)', 'TIN-4443', 8, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (411, 'PENGANTAR EKONOMIKA', 'TIN-1140', 2, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (412, 'MANAJEMEN DAN TEKNOLOGI GUDANG (P)', 'TIN-4431', 7, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (413, 'APLIKASI ERGONOMI INDUSTRI (P)', 'TIN-4462', 7, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (414, 'MEKANIKA TEKNIK', 'TIN-1157', 2, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (415, 'SISTEM MANAJEMEN PERAWATAN (P)', 'TIN-4455', 8, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (416, 'PSIKOLOGI INDUSTRI', 'TIN-2242', 4, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (417, 'BAHASA INGGRIS', 'UMG-1113', 2, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', NULL);
INSERT INTO public.mata_kuliah VALUES (418, 'ANALISIS DAN ESTIMASI BIAYA', 'TIN-2241', 4, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (419, 'ELEKTRONIKA INDUSTRI', 'TIN-2253', 6, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 11);
INSERT INTO public.mata_kuliah VALUES (420, 'STRATEGI ALGORITMA*', 'INF-55201-206', 3, 4, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (421, 'MATEMATIKA DASAR I', 'INF-55201-101', 1, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (422, 'KECERDASAN BUATAN', 'INF-55201-305', 5, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (423, 'SISTEM TERTANAM', 'INF-55201-304', 5, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (424, 'PERANCANGAN BASIS DATA', 'INF-55201-201', 3, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (425, 'RISET OPERASI', 'INF-55201-308', 5, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (426, 'PENULISAN PROPOSAL TUGAS AKHIR', 'INF-55201-310', 5, 2, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (427, 'DASAR PEMROGRAMAN*', 'INF-55201-103', 1, 4, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (428, 'METODE NUMERIK*', 'INF-55201-204', 3, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (429, 'SISTEM OPERASI*', 'INF-55201-207', 3, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (430, 'KOMPUTASI AWAN (PL)', 'INF 55201 523', 7, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (431, 'LOGIKA INFORMATIKA', 'INF-55201-102', 1, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (432, 'MATEMATIKA DISKRIT', 'INF-55201-203', 3, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (433, 'TEKNOPRENEUR*', 'INF-55201-401', 7, 3, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 12);
INSERT INTO public.mata_kuliah VALUES (434, 'PEMROGRAMAN JARINGAN*', 'INF-55201-303', 5, 3, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (435, 'INTERAKSI MANUSIA DAN KOMPUTER', 'INF-55201-301', 5, 2, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (436, 'PEMROGRAMAN WEB*', 'INF-55201-302', 5, 4, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (437, 'PENGANTAR TEKNIK INFORMATIKA', 'INF-55201-104', 1, 2, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (438, 'TEORI GRAF', 'INF-55201-202', 3, 2, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (439, 'MANAJEMEN PROYEK PERANGKAT LUNAK', 'INF-55201-306', 5, 2, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (440, 'JARINGAN KOMPUTER*', 'INF-55201-205', 3, 4, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (441, 'KRIPTOGRAFI (PL)', 'INF-55201-538', 7, 3, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (442, 'SIG II (PL)', 'INF-55201-532', 7, 3, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (443, 'PEMROGRAMAN PERANGKAT BERGERAK (PL)', 'INF-55201-515', 7, 3, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 12);
INSERT INTO public.mata_kuliah VALUES (444, 'BAHASA INGGRIS', 'UMG-55201-103', 1, 2, '2020-09-03 14:18:12', '2020-09-03 14:18:12', NULL);
INSERT INTO public.mata_kuliah VALUES (445, 'TEKNOLOGI POLP DAN KERTAS (P)', 'TKM-606', 7, 2, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 13);
INSERT INTO public.mata_kuliah VALUES (446, 'KIMIA DASAR', 'TKM-101', 1, 3, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 13);
INSERT INTO public.mata_kuliah VALUES (447, 'AZAZ TEKNIK KIMIA II', 'TKM-303', 3, 3, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 13);
INSERT INTO public.mata_kuliah VALUES (448, 'KIMIA FISIKA I', 'TKM-301', 3, 2, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 13);
INSERT INTO public.mata_kuliah VALUES (449, 'PERPINDAHAN PANAS', 'TKM-501', 5, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (450, 'PENGETAHUAN BAHAN DAN KOROSI', 'TKM-505', 5, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (451, 'KIMIA ORGANIK I', 'TKM-103', 1, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (452, 'MATEMATIKA TEKNIK KIMIA I', 'TKM-304', 3, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (453, 'PENGENALAN TEKNIK KIMIA & INDUSTRI', 'TKM-105', 1, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (454, 'TEKNOLOGI MEMBRAN (P)', 'TKM-609', 7, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (455, 'PENGENDALIAN PROSES TEKNIK KIMIA', 'TKM-502', 5, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (456, 'MANAJEMEN BISNIS', 'TEK-701', 7, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (457, 'ELEKTROKIMIA', 'TKM-508', 5, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (458, 'PERANCANGAN PABRIK KIMIA II', 'TKM-701', 7, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (459, 'FISIKA DASAR I', 'TEK-102', 1, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (460, 'OPERASI TEKNIK KIMIA I', 'TKM-305', 3, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (461, 'EKONOMI TEKNIK', 'TEK-501', 5, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (462, 'PENGENDALIAN KUALITAS', 'TKM-703', 7, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (463, 'OPERASI TEKNIK KIMIA III', 'TKM-503', 5, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (464, 'PROSES INDUSTRI KIMIA', 'TKM-306', 3, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (465, 'STRUKTUR DAN SIFAT KIMIA MATERIAL (P)', 'TKM-612', 7, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (466, 'TERMODINAMIKA TEKNIK KIMIA I', 'TKM-307', 3, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (467, 'KALKULUS I', 'TEK-101', 1, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (468, 'TEKNIK REAKSI KIMIA II', 'TKM-504', 5, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (469, 'PEMODELAN MATEMATIS & PENYELESAIAN NUMER', 'TKM-308', 3, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (470, 'OPTIMASI SISTEM TEKNIK KIMIA', 'TKM-704', 7, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (471, 'ENERGI BARU DAN TERBARUKAN (P)', 'TKM-610', 7, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (472, 'TEKNOLOGI KOROSI (P)', 'TKM-608', 7, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (473, 'KIMIA ANALISIS', 'TEK-204', 2, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (474, 'OPERASI TEKNIK KIMIA II', 'TKM-404', 4, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (475, 'PEMROGRAMAN KOMPUTER', 'TEK-401', 4, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (476, 'TEKNOLOGI PENGOLAHAN CPO (P)', 'TKM-706', 8, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (477, 'FISIKA DASAR II', 'TEK-202', 2, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (478, 'MATEMATIKA TEKNIK KIMIA II', 'TKM-403', 4, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (479, 'KIMIA ORGANIK II', 'TKM-202', 2, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (480, 'METODOLOGI PENELITIAN', 'TEK-601', 6, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (481, 'TERMODINAMIKA TEKNIK KIMIA II', 'TKM-406', 4, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (482, 'REAKTOR KIMIA', 'TKM-602', 6, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (483, 'KOMPUTASI DINAMIKA FLUIDA (P)', 'TKM-710', 8, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (484, 'ETIKA PROFESI', 'UMG-801', 8, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', NULL);
INSERT INTO public.mata_kuliah VALUES (485, 'KALKULUS II', 'TEK-201', 2, 3, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (486, 'KIMIA FISIKA II', 'TKM-401', 4, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (487, 'PERANCANGAN PABRIK KIMIA I', 'TKM-601', 6, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (488, 'TEKNOLOGI PENGOLAHAN LIMBAH (P)', 'TKM-709', 8, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (489, 'PROSES PERPINDAHAN', 'TKM-603', 6, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (490, 'TEKNIK REAKSI KIMIA I', 'TKM-405', 4, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (491, 'TEKNOLOGI POLIMER (P)', 'TKM-705', 8, 2, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 13);
INSERT INTO public.mata_kuliah VALUES (492, 'ALAT INDUSTRI KIMIA', 'TKM-604', 6, 3, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 13);
INSERT INTO public.mata_kuliah VALUES (493, 'PERANCANGAN ALAT PROSES', 'TKM-605', 6, 2, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 13);
INSERT INTO public.mata_kuliah VALUES (494, 'UTILITAS', 'TKM-407', 4, 3, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 13);
INSERT INTO public.mata_kuliah VALUES (495, 'TEKNOLOGI PETROKIMIA DAN GAS (P)', 'TKM-708', 8, 2, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 13);
INSERT INTO public.mata_kuliah VALUES (496, 'AZAZ TEKNIK KIMIA', 'TKM-201', 2, 2, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 13);
INSERT INTO public.mata_kuliah VALUES (497, 'KEWIRAUSAHAAN', 'UMG-802', 8, 2, '2020-09-03 14:18:14', '2020-09-03 14:18:14', NULL);
INSERT INTO public.mata_kuliah VALUES (498, 'TEKNOLOGI BIOMASA (P)', 'TKM-707', 8, 2, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 13);
INSERT INTO public.mata_kuliah VALUES (499, 'TEKNOLOGI KATALIS (P)', 'TKM-711', 8, 2, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 13);
INSERT INTO public.mata_kuliah VALUES (500, 'ANALISA NUMERIK & PEMROGRAMAN', 'TMK-311', 3, 3, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 14);
INSERT INTO public.mata_kuliah VALUES (501, 'SISTEM TENAGA UAP', 'TMK-743', 7, 3, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 14);
INSERT INTO public.mata_kuliah VALUES (502, 'THERMODINAMIKA I', 'TMK-316', 3, 2, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 14);
INSERT INTO public.mata_kuliah VALUES (503, 'PROBABILITAS & STATISTIK', 'TMK-104', 1, 3, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 14);
INSERT INTO public.mata_kuliah VALUES (504, 'PENGANTAR SISTEM KONTROL', 'TMK-529', 5, 2, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 14);
INSERT INTO public.mata_kuliah VALUES (505, 'PERPINDAHAN PANAS I', 'TMK-318', 3, 2, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 14);
INSERT INTO public.mata_kuliah VALUES (506, 'KEWIRAUSAHAAN', 'TMK-740', 7, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (507, 'METODOLOGI PENELITIAN', 'TMK-532', 5, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (508, 'PEMILIHAN BAHAN DAN PROSES', 'TMK-530', 5, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (509, 'KALKULUS I', 'TMK-102', 1, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (510, 'FISIKA DASAR II', 'TMK-313', 3, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (511, 'MESIN PENDINGIN DAN PEMANAS', 'TMK-744', 7, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (512, 'MENGGAMBAR TEKNIK & TUGAS', 'TMK-314', 3, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (513, 'MATEMATIKA TEKNIK I', 'TMK-103', 1, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (514, 'TEKNOLOGI PEMBAKARAN', 'TMK-528', 5, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (515, 'MATERIAL TEKNIK', 'TMK-101', 1, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (516, 'PROSES MANUFAKTUR II', 'TMK-526', 5, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (517, 'ELEMEN MESIN I', 'TMK-527', 5, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (518, 'MEKANIKA FLUIDA I', 'TMK-317', 3, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (519, 'MEKANIKA GETARAN', 'TMK-315', 3, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (520, 'MOTOR BAKAR', 'TMK-741', 7, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (521, 'TEKNIK TENAGA LISTRIK', 'TMK-531', 5, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (522, 'MEKANIKA KEKUATAN MATERIAL', 'TMK-312', 3, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (523, 'TURBIN GAS & SISTEM PROPULSI', 'TMK-742', 7, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (524, 'PENGUKURAN TEKNIK DAN INSTRUMENTASI', 'TMK-636', 6, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (525, 'PEMROGRAMAN KOMPUTER', 'TMK-423', 4, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (526, 'MANAJEMEN PERAWATAN (P)', 'TMK-853', 8, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (527, 'KINEMATIKA DAN DINAMIKA', 'TMK-210', 2, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (528, 'ELEMEN MESIN II', 'TMK-633', 6, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (529, 'MEKATRONIKA', 'TMK-635', 6, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (530, 'THERMODINAMIKA II', 'TMK-419', 4, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (531, 'KIMIA DASAR', 'TMK-208', 2, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (532, 'METROLOGI INDUSTRI', 'TMK-634', 6, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (533, 'MEKANIKA FLUIDA II', 'TMK-420', 4, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (534, 'FISIKA DASAR I', 'TMK-207', 2, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (535, 'PERPINDAHAN PANAS II', 'TMK-421', 4, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (536, 'TURBIN AIR (P)', 'TMK-851', 8, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (537, 'TEKNOLOGI TEPAT GUNA', 'TMK-848', 8, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (538, 'KESELAMATAN DAN KESEHATAN KERJA (P)', 'TMK-856', 8, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (539, 'MANAJEMEN EKONOMI DAN REKAYASA', 'TMK-422', 4, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (540, 'MATEMATIKA TEKNIK II', 'TMK-206', 2, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (541, 'MESIN KONVERSI ENERGI', 'TMK-637', 6, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (542, 'MENGGAMBAR MESIN & TUGAS', 'TMK-424', 4, 2, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (543, 'KALKULUS II', 'TMK-205', 2, 3, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 14);
INSERT INTO public.mata_kuliah VALUES (544, 'NC+CNC', 'TMK-639', 6, 3, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 14);
INSERT INTO public.mata_kuliah VALUES (545, 'MANAJEMEN ENERGI (P)', 'TMK-846', 8, 3, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 14);
INSERT INTO public.mata_kuliah VALUES (546, 'PROSES MANUFAKTUR I', 'TMK-425', 4, 3, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 14);


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.migrations VALUES (1, '2014_10_12_000000_create_users_table', 1);
INSERT INTO public.migrations VALUES (2, '2014_10_12_100000_create_password_resets_table', 1);
INSERT INTO public.migrations VALUES (3, '2019_08_19_000000_create_failed_jobs_table', 1);
INSERT INTO public.migrations VALUES (4, '2020_03_18_105820_create_ruangan_table', 1);
INSERT INTO public.migrations VALUES (5, '2020_03_18_105830_create_kegiatan_table', 1);
INSERT INTO public.migrations VALUES (6, '2020_03_18_110730_create_pola_perulangan_table', 1);
INSERT INTO public.migrations VALUES (7, '2020_03_24_014318_create_mata_kuliah_table', 1);
INSERT INTO public.migrations VALUES (8, '2020_03_24_014319_create_kelas_mata_kuliah_table', 1);
INSERT INTO public.migrations VALUES (9, '2020_03_25_025036_create_last_day_stored_procedure', 1);
INSERT INTO public.migrations VALUES (10, '2020_03_25_025540_create_week_of_month_stored_procedure', 1);
INSERT INTO public.migrations VALUES (11, '2020_03_25_051301_create_program_studi_table', 1);
INSERT INTO public.migrations VALUES (12, '2020_03_25_051352_create_tahun_ajaran_table', 1);
INSERT INTO public.migrations VALUES (13, '2020_03_25_081935_add_program_studi_id_to_mata_kuliah_table', 1);
INSERT INTO public.migrations VALUES (14, '2020_03_25_082438_create_tipe_semester_table', 1);
INSERT INTO public.migrations VALUES (15, '2020_03_25_082711_add_tipe_semester_id_to_kelas_mata_kuliah', 1);
INSERT INTO public.migrations VALUES (16, '2020_03_25_084450_add_tahun_ajaran_id_to_kelas_mata_kuliah', 1);
INSERT INTO public.migrations VALUES (17, '2020_03_25_110241_add_program_studi_id_to_kelas_mata_kuliah', 1);
INSERT INTO public.migrations VALUES (18, '2020_03_27_023019_create_jadwal_view', 1);
INSERT INTO public.migrations VALUES (19, '2020_03_30_233610_add_mata_kuliah_id_to_kegiatan', 1);
INSERT INTO public.migrations VALUES (20, '2020_03_31_130459_create_seminar_table', 1);
INSERT INTO public.migrations VALUES (21, '2020_03_31_231427_add_constraint_to_kelas_mata_kuliah', 1);
INSERT INTO public.migrations VALUES (22, '2020_08_09_085954_drop_seminar_table', 1);


--
-- Data for Name: password_resets; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--



--
-- Data for Name: pola_perulangan; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.pola_perulangan VALUES (1, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 1);
INSERT INTO public.pola_perulangan VALUES (2, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 2);
INSERT INTO public.pola_perulangan VALUES (3, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 3);
INSERT INTO public.pola_perulangan VALUES (4, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 4);
INSERT INTO public.pola_perulangan VALUES (5, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 5);
INSERT INTO public.pola_perulangan VALUES (6, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 6);
INSERT INTO public.pola_perulangan VALUES (7, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 7);
INSERT INTO public.pola_perulangan VALUES (8, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 8);
INSERT INTO public.pola_perulangan VALUES (9, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 9);
INSERT INTO public.pola_perulangan VALUES (10, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 10);
INSERT INTO public.pola_perulangan VALUES (11, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 11);
INSERT INTO public.pola_perulangan VALUES (12, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 12);
INSERT INTO public.pola_perulangan VALUES (13, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 13);
INSERT INTO public.pola_perulangan VALUES (14, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 14);
INSERT INTO public.pola_perulangan VALUES (15, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 15);
INSERT INTO public.pola_perulangan VALUES (16, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 16);
INSERT INTO public.pola_perulangan VALUES (17, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 17);
INSERT INTO public.pola_perulangan VALUES (18, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 18);
INSERT INTO public.pola_perulangan VALUES (19, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 19);
INSERT INTO public.pola_perulangan VALUES (20, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 20);
INSERT INTO public.pola_perulangan VALUES (21, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 21);
INSERT INTO public.pola_perulangan VALUES (22, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 22);
INSERT INTO public.pola_perulangan VALUES (23, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 23);
INSERT INTO public.pola_perulangan VALUES (24, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 24);
INSERT INTO public.pola_perulangan VALUES (25, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 25);
INSERT INTO public.pola_perulangan VALUES (26, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 26);
INSERT INTO public.pola_perulangan VALUES (27, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 27);
INSERT INTO public.pola_perulangan VALUES (28, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 28);
INSERT INTO public.pola_perulangan VALUES (29, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 29);
INSERT INTO public.pola_perulangan VALUES (30, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 30);
INSERT INTO public.pola_perulangan VALUES (31, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 31);
INSERT INTO public.pola_perulangan VALUES (32, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 32);
INSERT INTO public.pola_perulangan VALUES (33, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 33);
INSERT INTO public.pola_perulangan VALUES (34, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 34);
INSERT INTO public.pola_perulangan VALUES (35, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 35);
INSERT INTO public.pola_perulangan VALUES (36, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 36);
INSERT INTO public.pola_perulangan VALUES (37, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 37);
INSERT INTO public.pola_perulangan VALUES (38, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 38);
INSERT INTO public.pola_perulangan VALUES (39, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 39);
INSERT INTO public.pola_perulangan VALUES (40, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49', 40);
INSERT INTO public.pola_perulangan VALUES (41, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 41);
INSERT INTO public.pola_perulangan VALUES (42, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 42);
INSERT INTO public.pola_perulangan VALUES (43, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 43);
INSERT INTO public.pola_perulangan VALUES (44, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 44);
INSERT INTO public.pola_perulangan VALUES (45, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 45);
INSERT INTO public.pola_perulangan VALUES (46, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 46);
INSERT INTO public.pola_perulangan VALUES (47, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 47);
INSERT INTO public.pola_perulangan VALUES (48, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 48);
INSERT INTO public.pola_perulangan VALUES (49, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 49);
INSERT INTO public.pola_perulangan VALUES (50, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 50);
INSERT INTO public.pola_perulangan VALUES (51, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 51);
INSERT INTO public.pola_perulangan VALUES (52, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 52);
INSERT INTO public.pola_perulangan VALUES (53, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 53);
INSERT INTO public.pola_perulangan VALUES (54, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 54);
INSERT INTO public.pola_perulangan VALUES (55, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 55);
INSERT INTO public.pola_perulangan VALUES (56, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 56);
INSERT INTO public.pola_perulangan VALUES (57, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 57);
INSERT INTO public.pola_perulangan VALUES (58, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 58);
INSERT INTO public.pola_perulangan VALUES (59, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 59);
INSERT INTO public.pola_perulangan VALUES (60, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 60);
INSERT INTO public.pola_perulangan VALUES (61, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 61);
INSERT INTO public.pola_perulangan VALUES (62, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 62);
INSERT INTO public.pola_perulangan VALUES (63, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 63);
INSERT INTO public.pola_perulangan VALUES (64, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 64);
INSERT INTO public.pola_perulangan VALUES (65, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 65);
INSERT INTO public.pola_perulangan VALUES (66, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 66);
INSERT INTO public.pola_perulangan VALUES (67, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 67);
INSERT INTO public.pola_perulangan VALUES (68, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 68);
INSERT INTO public.pola_perulangan VALUES (69, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 69);
INSERT INTO public.pola_perulangan VALUES (70, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 70);
INSERT INTO public.pola_perulangan VALUES (71, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 71);
INSERT INTO public.pola_perulangan VALUES (72, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 72);
INSERT INTO public.pola_perulangan VALUES (73, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 73);
INSERT INTO public.pola_perulangan VALUES (74, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 74);
INSERT INTO public.pola_perulangan VALUES (75, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 75);
INSERT INTO public.pola_perulangan VALUES (76, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 76);
INSERT INTO public.pola_perulangan VALUES (77, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 77);
INSERT INTO public.pola_perulangan VALUES (78, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 78);
INSERT INTO public.pola_perulangan VALUES (79, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 79);
INSERT INTO public.pola_perulangan VALUES (80, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 80);
INSERT INTO public.pola_perulangan VALUES (81, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 81);
INSERT INTO public.pola_perulangan VALUES (82, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 82);
INSERT INTO public.pola_perulangan VALUES (83, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 83);
INSERT INTO public.pola_perulangan VALUES (84, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 84);
INSERT INTO public.pola_perulangan VALUES (85, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 85);
INSERT INTO public.pola_perulangan VALUES (86, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 86);
INSERT INTO public.pola_perulangan VALUES (87, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 87);
INSERT INTO public.pola_perulangan VALUES (88, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 88);
INSERT INTO public.pola_perulangan VALUES (89, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 89);
INSERT INTO public.pola_perulangan VALUES (90, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 90);
INSERT INTO public.pola_perulangan VALUES (91, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 91);
INSERT INTO public.pola_perulangan VALUES (92, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 92);
INSERT INTO public.pola_perulangan VALUES (93, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 93);
INSERT INTO public.pola_perulangan VALUES (94, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 94);
INSERT INTO public.pola_perulangan VALUES (95, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 95);
INSERT INTO public.pola_perulangan VALUES (96, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 96);
INSERT INTO public.pola_perulangan VALUES (97, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 97);
INSERT INTO public.pola_perulangan VALUES (98, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 98);
INSERT INTO public.pola_perulangan VALUES (99, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 99);
INSERT INTO public.pola_perulangan VALUES (100, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 100);
INSERT INTO public.pola_perulangan VALUES (101, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:50', '2020-09-03 14:17:50', 101);
INSERT INTO public.pola_perulangan VALUES (102, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 102);
INSERT INTO public.pola_perulangan VALUES (103, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 103);
INSERT INTO public.pola_perulangan VALUES (104, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 104);
INSERT INTO public.pola_perulangan VALUES (105, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 105);
INSERT INTO public.pola_perulangan VALUES (106, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 106);
INSERT INTO public.pola_perulangan VALUES (107, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 107);
INSERT INTO public.pola_perulangan VALUES (108, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 108);
INSERT INTO public.pola_perulangan VALUES (109, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 109);
INSERT INTO public.pola_perulangan VALUES (110, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 110);
INSERT INTO public.pola_perulangan VALUES (111, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 111);
INSERT INTO public.pola_perulangan VALUES (112, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 112);
INSERT INTO public.pola_perulangan VALUES (113, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 113);
INSERT INTO public.pola_perulangan VALUES (114, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 114);
INSERT INTO public.pola_perulangan VALUES (115, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 115);
INSERT INTO public.pola_perulangan VALUES (116, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 116);
INSERT INTO public.pola_perulangan VALUES (117, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 117);
INSERT INTO public.pola_perulangan VALUES (118, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 118);
INSERT INTO public.pola_perulangan VALUES (119, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 119);
INSERT INTO public.pola_perulangan VALUES (120, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 120);
INSERT INTO public.pola_perulangan VALUES (121, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 121);
INSERT INTO public.pola_perulangan VALUES (122, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 122);
INSERT INTO public.pola_perulangan VALUES (123, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 123);
INSERT INTO public.pola_perulangan VALUES (124, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 124);
INSERT INTO public.pola_perulangan VALUES (125, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 125);
INSERT INTO public.pola_perulangan VALUES (126, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 126);
INSERT INTO public.pola_perulangan VALUES (127, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 127);
INSERT INTO public.pola_perulangan VALUES (128, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 128);
INSERT INTO public.pola_perulangan VALUES (129, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 129);
INSERT INTO public.pola_perulangan VALUES (130, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 130);
INSERT INTO public.pola_perulangan VALUES (131, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 131);
INSERT INTO public.pola_perulangan VALUES (132, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 132);
INSERT INTO public.pola_perulangan VALUES (133, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 133);
INSERT INTO public.pola_perulangan VALUES (134, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 134);
INSERT INTO public.pola_perulangan VALUES (135, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 135);
INSERT INTO public.pola_perulangan VALUES (136, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 136);
INSERT INTO public.pola_perulangan VALUES (137, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 137);
INSERT INTO public.pola_perulangan VALUES (138, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 138);
INSERT INTO public.pola_perulangan VALUES (139, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 139);
INSERT INTO public.pola_perulangan VALUES (140, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 140);
INSERT INTO public.pola_perulangan VALUES (141, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 141);
INSERT INTO public.pola_perulangan VALUES (142, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 142);
INSERT INTO public.pola_perulangan VALUES (143, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 143);
INSERT INTO public.pola_perulangan VALUES (144, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 144);
INSERT INTO public.pola_perulangan VALUES (145, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 145);
INSERT INTO public.pola_perulangan VALUES (146, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 146);
INSERT INTO public.pola_perulangan VALUES (147, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 147);
INSERT INTO public.pola_perulangan VALUES (148, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 148);
INSERT INTO public.pola_perulangan VALUES (149, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 149);
INSERT INTO public.pola_perulangan VALUES (150, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 150);
INSERT INTO public.pola_perulangan VALUES (151, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 151);
INSERT INTO public.pola_perulangan VALUES (152, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:51', '2020-09-03 14:17:51', 152);
INSERT INTO public.pola_perulangan VALUES (153, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 153);
INSERT INTO public.pola_perulangan VALUES (154, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 154);
INSERT INTO public.pola_perulangan VALUES (155, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 155);
INSERT INTO public.pola_perulangan VALUES (156, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 156);
INSERT INTO public.pola_perulangan VALUES (157, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 157);
INSERT INTO public.pola_perulangan VALUES (158, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 158);
INSERT INTO public.pola_perulangan VALUES (159, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 159);
INSERT INTO public.pola_perulangan VALUES (160, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 160);
INSERT INTO public.pola_perulangan VALUES (161, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 161);
INSERT INTO public.pola_perulangan VALUES (162, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 162);
INSERT INTO public.pola_perulangan VALUES (163, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 163);
INSERT INTO public.pola_perulangan VALUES (164, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 164);
INSERT INTO public.pola_perulangan VALUES (165, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 165);
INSERT INTO public.pola_perulangan VALUES (166, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 166);
INSERT INTO public.pola_perulangan VALUES (167, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 167);
INSERT INTO public.pola_perulangan VALUES (168, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 168);
INSERT INTO public.pola_perulangan VALUES (169, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 169);
INSERT INTO public.pola_perulangan VALUES (170, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 170);
INSERT INTO public.pola_perulangan VALUES (171, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 171);
INSERT INTO public.pola_perulangan VALUES (172, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 172);
INSERT INTO public.pola_perulangan VALUES (173, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 173);
INSERT INTO public.pola_perulangan VALUES (174, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 174);
INSERT INTO public.pola_perulangan VALUES (175, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 175);
INSERT INTO public.pola_perulangan VALUES (176, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 176);
INSERT INTO public.pola_perulangan VALUES (177, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 177);
INSERT INTO public.pola_perulangan VALUES (178, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 178);
INSERT INTO public.pola_perulangan VALUES (179, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 179);
INSERT INTO public.pola_perulangan VALUES (180, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 180);
INSERT INTO public.pola_perulangan VALUES (181, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 181);
INSERT INTO public.pola_perulangan VALUES (182, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 182);
INSERT INTO public.pola_perulangan VALUES (183, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 183);
INSERT INTO public.pola_perulangan VALUES (184, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 184);
INSERT INTO public.pola_perulangan VALUES (185, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 185);
INSERT INTO public.pola_perulangan VALUES (186, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 186);
INSERT INTO public.pola_perulangan VALUES (187, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 187);
INSERT INTO public.pola_perulangan VALUES (188, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 188);
INSERT INTO public.pola_perulangan VALUES (189, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 189);
INSERT INTO public.pola_perulangan VALUES (190, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 190);
INSERT INTO public.pola_perulangan VALUES (191, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 191);
INSERT INTO public.pola_perulangan VALUES (192, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 192);
INSERT INTO public.pola_perulangan VALUES (193, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 193);
INSERT INTO public.pola_perulangan VALUES (194, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 194);
INSERT INTO public.pola_perulangan VALUES (195, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 195);
INSERT INTO public.pola_perulangan VALUES (196, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 196);
INSERT INTO public.pola_perulangan VALUES (197, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 197);
INSERT INTO public.pola_perulangan VALUES (198, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 198);
INSERT INTO public.pola_perulangan VALUES (199, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 199);
INSERT INTO public.pola_perulangan VALUES (200, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 200);
INSERT INTO public.pola_perulangan VALUES (201, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 201);
INSERT INTO public.pola_perulangan VALUES (202, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 202);
INSERT INTO public.pola_perulangan VALUES (203, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 203);
INSERT INTO public.pola_perulangan VALUES (204, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 204);
INSERT INTO public.pola_perulangan VALUES (205, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 205);
INSERT INTO public.pola_perulangan VALUES (206, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 206);
INSERT INTO public.pola_perulangan VALUES (207, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 207);
INSERT INTO public.pola_perulangan VALUES (208, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:52', '2020-09-03 14:17:52', 208);
INSERT INTO public.pola_perulangan VALUES (209, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 209);
INSERT INTO public.pola_perulangan VALUES (210, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 210);
INSERT INTO public.pola_perulangan VALUES (211, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 211);
INSERT INTO public.pola_perulangan VALUES (212, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 212);
INSERT INTO public.pola_perulangan VALUES (213, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 213);
INSERT INTO public.pola_perulangan VALUES (214, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 214);
INSERT INTO public.pola_perulangan VALUES (215, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 215);
INSERT INTO public.pola_perulangan VALUES (216, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 216);
INSERT INTO public.pola_perulangan VALUES (217, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 217);
INSERT INTO public.pola_perulangan VALUES (218, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 218);
INSERT INTO public.pola_perulangan VALUES (219, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 219);
INSERT INTO public.pola_perulangan VALUES (220, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 220);
INSERT INTO public.pola_perulangan VALUES (221, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 221);
INSERT INTO public.pola_perulangan VALUES (222, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 222);
INSERT INTO public.pola_perulangan VALUES (223, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 223);
INSERT INTO public.pola_perulangan VALUES (224, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 224);
INSERT INTO public.pola_perulangan VALUES (225, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 225);
INSERT INTO public.pola_perulangan VALUES (226, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 226);
INSERT INTO public.pola_perulangan VALUES (227, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 227);
INSERT INTO public.pola_perulangan VALUES (228, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 228);
INSERT INTO public.pola_perulangan VALUES (229, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 229);
INSERT INTO public.pola_perulangan VALUES (230, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 230);
INSERT INTO public.pola_perulangan VALUES (231, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 231);
INSERT INTO public.pola_perulangan VALUES (232, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 232);
INSERT INTO public.pola_perulangan VALUES (233, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 233);
INSERT INTO public.pola_perulangan VALUES (234, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 234);
INSERT INTO public.pola_perulangan VALUES (235, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 235);
INSERT INTO public.pola_perulangan VALUES (236, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 236);
INSERT INTO public.pola_perulangan VALUES (237, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 237);
INSERT INTO public.pola_perulangan VALUES (238, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 238);
INSERT INTO public.pola_perulangan VALUES (239, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 239);
INSERT INTO public.pola_perulangan VALUES (240, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 240);
INSERT INTO public.pola_perulangan VALUES (241, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 241);
INSERT INTO public.pola_perulangan VALUES (242, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 242);
INSERT INTO public.pola_perulangan VALUES (243, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 243);
INSERT INTO public.pola_perulangan VALUES (244, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 244);
INSERT INTO public.pola_perulangan VALUES (245, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 245);
INSERT INTO public.pola_perulangan VALUES (246, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 246);
INSERT INTO public.pola_perulangan VALUES (247, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 247);
INSERT INTO public.pola_perulangan VALUES (248, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 248);
INSERT INTO public.pola_perulangan VALUES (249, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 249);
INSERT INTO public.pola_perulangan VALUES (250, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 250);
INSERT INTO public.pola_perulangan VALUES (251, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 251);
INSERT INTO public.pola_perulangan VALUES (252, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 252);
INSERT INTO public.pola_perulangan VALUES (253, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 253);
INSERT INTO public.pola_perulangan VALUES (254, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 254);
INSERT INTO public.pola_perulangan VALUES (255, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 255);
INSERT INTO public.pola_perulangan VALUES (256, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 256);
INSERT INTO public.pola_perulangan VALUES (257, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 257);
INSERT INTO public.pola_perulangan VALUES (258, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 258);
INSERT INTO public.pola_perulangan VALUES (259, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 259);
INSERT INTO public.pola_perulangan VALUES (260, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 260);
INSERT INTO public.pola_perulangan VALUES (261, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 261);
INSERT INTO public.pola_perulangan VALUES (262, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 262);
INSERT INTO public.pola_perulangan VALUES (263, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 263);
INSERT INTO public.pola_perulangan VALUES (264, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 264);
INSERT INTO public.pola_perulangan VALUES (265, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:53', '2020-09-03 14:17:53', 265);
INSERT INTO public.pola_perulangan VALUES (266, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 266);
INSERT INTO public.pola_perulangan VALUES (267, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 267);
INSERT INTO public.pola_perulangan VALUES (268, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 268);
INSERT INTO public.pola_perulangan VALUES (269, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 269);
INSERT INTO public.pola_perulangan VALUES (270, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 270);
INSERT INTO public.pola_perulangan VALUES (271, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 271);
INSERT INTO public.pola_perulangan VALUES (272, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 272);
INSERT INTO public.pola_perulangan VALUES (273, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 273);
INSERT INTO public.pola_perulangan VALUES (274, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 274);
INSERT INTO public.pola_perulangan VALUES (275, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 275);
INSERT INTO public.pola_perulangan VALUES (276, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 276);
INSERT INTO public.pola_perulangan VALUES (277, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 277);
INSERT INTO public.pola_perulangan VALUES (278, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 278);
INSERT INTO public.pola_perulangan VALUES (279, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 279);
INSERT INTO public.pola_perulangan VALUES (280, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 280);
INSERT INTO public.pola_perulangan VALUES (281, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 281);
INSERT INTO public.pola_perulangan VALUES (282, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 282);
INSERT INTO public.pola_perulangan VALUES (283, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 283);
INSERT INTO public.pola_perulangan VALUES (284, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 284);
INSERT INTO public.pola_perulangan VALUES (285, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 285);
INSERT INTO public.pola_perulangan VALUES (286, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 286);
INSERT INTO public.pola_perulangan VALUES (287, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 287);
INSERT INTO public.pola_perulangan VALUES (288, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 288);
INSERT INTO public.pola_perulangan VALUES (289, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 289);
INSERT INTO public.pola_perulangan VALUES (290, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 290);
INSERT INTO public.pola_perulangan VALUES (291, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 291);
INSERT INTO public.pola_perulangan VALUES (292, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 292);
INSERT INTO public.pola_perulangan VALUES (293, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 293);
INSERT INTO public.pola_perulangan VALUES (294, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 294);
INSERT INTO public.pola_perulangan VALUES (295, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 295);
INSERT INTO public.pola_perulangan VALUES (296, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 296);
INSERT INTO public.pola_perulangan VALUES (297, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 297);
INSERT INTO public.pola_perulangan VALUES (298, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 298);
INSERT INTO public.pola_perulangan VALUES (299, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 299);
INSERT INTO public.pola_perulangan VALUES (300, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 300);
INSERT INTO public.pola_perulangan VALUES (301, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 301);
INSERT INTO public.pola_perulangan VALUES (302, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 302);
INSERT INTO public.pola_perulangan VALUES (303, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 303);
INSERT INTO public.pola_perulangan VALUES (304, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 304);
INSERT INTO public.pola_perulangan VALUES (305, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 305);
INSERT INTO public.pola_perulangan VALUES (306, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 306);
INSERT INTO public.pola_perulangan VALUES (307, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 307);
INSERT INTO public.pola_perulangan VALUES (308, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 308);
INSERT INTO public.pola_perulangan VALUES (309, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 309);
INSERT INTO public.pola_perulangan VALUES (310, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 310);
INSERT INTO public.pola_perulangan VALUES (311, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 311);
INSERT INTO public.pola_perulangan VALUES (312, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 312);
INSERT INTO public.pola_perulangan VALUES (313, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 313);
INSERT INTO public.pola_perulangan VALUES (314, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 314);
INSERT INTO public.pola_perulangan VALUES (315, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 315);
INSERT INTO public.pola_perulangan VALUES (316, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 316);
INSERT INTO public.pola_perulangan VALUES (317, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 317);
INSERT INTO public.pola_perulangan VALUES (318, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 318);
INSERT INTO public.pola_perulangan VALUES (319, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 319);
INSERT INTO public.pola_perulangan VALUES (320, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 320);
INSERT INTO public.pola_perulangan VALUES (321, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 321);
INSERT INTO public.pola_perulangan VALUES (322, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 322);
INSERT INTO public.pola_perulangan VALUES (323, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 323);
INSERT INTO public.pola_perulangan VALUES (324, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 324);
INSERT INTO public.pola_perulangan VALUES (325, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:54', '2020-09-03 14:17:54', 325);
INSERT INTO public.pola_perulangan VALUES (326, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 326);
INSERT INTO public.pola_perulangan VALUES (327, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 327);
INSERT INTO public.pola_perulangan VALUES (328, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 328);
INSERT INTO public.pola_perulangan VALUES (329, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 329);
INSERT INTO public.pola_perulangan VALUES (330, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 330);
INSERT INTO public.pola_perulangan VALUES (331, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 331);
INSERT INTO public.pola_perulangan VALUES (332, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 332);
INSERT INTO public.pola_perulangan VALUES (333, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 333);
INSERT INTO public.pola_perulangan VALUES (334, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 334);
INSERT INTO public.pola_perulangan VALUES (335, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 335);
INSERT INTO public.pola_perulangan VALUES (336, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 336);
INSERT INTO public.pola_perulangan VALUES (337, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 337);
INSERT INTO public.pola_perulangan VALUES (338, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 338);
INSERT INTO public.pola_perulangan VALUES (339, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 339);
INSERT INTO public.pola_perulangan VALUES (340, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 340);
INSERT INTO public.pola_perulangan VALUES (341, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 341);
INSERT INTO public.pola_perulangan VALUES (342, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 342);
INSERT INTO public.pola_perulangan VALUES (343, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 343);
INSERT INTO public.pola_perulangan VALUES (344, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 344);
INSERT INTO public.pola_perulangan VALUES (345, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 345);
INSERT INTO public.pola_perulangan VALUES (346, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 346);
INSERT INTO public.pola_perulangan VALUES (347, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 347);
INSERT INTO public.pola_perulangan VALUES (348, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 348);
INSERT INTO public.pola_perulangan VALUES (349, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 349);
INSERT INTO public.pola_perulangan VALUES (350, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 350);
INSERT INTO public.pola_perulangan VALUES (351, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 351);
INSERT INTO public.pola_perulangan VALUES (352, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 352);
INSERT INTO public.pola_perulangan VALUES (353, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 353);
INSERT INTO public.pola_perulangan VALUES (354, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 354);
INSERT INTO public.pola_perulangan VALUES (355, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 355);
INSERT INTO public.pola_perulangan VALUES (356, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 356);
INSERT INTO public.pola_perulangan VALUES (357, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 357);
INSERT INTO public.pola_perulangan VALUES (358, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 358);
INSERT INTO public.pola_perulangan VALUES (359, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 359);
INSERT INTO public.pola_perulangan VALUES (360, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 360);
INSERT INTO public.pola_perulangan VALUES (361, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 361);
INSERT INTO public.pola_perulangan VALUES (362, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 362);
INSERT INTO public.pola_perulangan VALUES (363, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:55', '2020-09-03 14:17:55', 363);
INSERT INTO public.pola_perulangan VALUES (364, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 364);
INSERT INTO public.pola_perulangan VALUES (365, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 365);
INSERT INTO public.pola_perulangan VALUES (366, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 366);
INSERT INTO public.pola_perulangan VALUES (367, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 367);
INSERT INTO public.pola_perulangan VALUES (368, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 368);
INSERT INTO public.pola_perulangan VALUES (369, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 369);
INSERT INTO public.pola_perulangan VALUES (370, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 370);
INSERT INTO public.pola_perulangan VALUES (371, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 371);
INSERT INTO public.pola_perulangan VALUES (372, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 372);
INSERT INTO public.pola_perulangan VALUES (373, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 373);
INSERT INTO public.pola_perulangan VALUES (374, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 374);
INSERT INTO public.pola_perulangan VALUES (375, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 375);
INSERT INTO public.pola_perulangan VALUES (376, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 376);
INSERT INTO public.pola_perulangan VALUES (377, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 377);
INSERT INTO public.pola_perulangan VALUES (378, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 378);
INSERT INTO public.pola_perulangan VALUES (379, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 379);
INSERT INTO public.pola_perulangan VALUES (380, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 380);
INSERT INTO public.pola_perulangan VALUES (381, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 381);
INSERT INTO public.pola_perulangan VALUES (382, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 382);
INSERT INTO public.pola_perulangan VALUES (383, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 383);
INSERT INTO public.pola_perulangan VALUES (384, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 384);
INSERT INTO public.pola_perulangan VALUES (385, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 385);
INSERT INTO public.pola_perulangan VALUES (386, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 386);
INSERT INTO public.pola_perulangan VALUES (387, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 387);
INSERT INTO public.pola_perulangan VALUES (388, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 388);
INSERT INTO public.pola_perulangan VALUES (389, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 389);
INSERT INTO public.pola_perulangan VALUES (390, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 390);
INSERT INTO public.pola_perulangan VALUES (391, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 391);
INSERT INTO public.pola_perulangan VALUES (392, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 392);
INSERT INTO public.pola_perulangan VALUES (393, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 393);
INSERT INTO public.pola_perulangan VALUES (394, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 394);
INSERT INTO public.pola_perulangan VALUES (395, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 395);
INSERT INTO public.pola_perulangan VALUES (396, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 396);
INSERT INTO public.pola_perulangan VALUES (397, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 397);
INSERT INTO public.pola_perulangan VALUES (398, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 398);
INSERT INTO public.pola_perulangan VALUES (399, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:56', '2020-09-03 14:17:56', 399);
INSERT INTO public.pola_perulangan VALUES (400, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 400);
INSERT INTO public.pola_perulangan VALUES (401, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 401);
INSERT INTO public.pola_perulangan VALUES (402, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 402);
INSERT INTO public.pola_perulangan VALUES (403, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 403);
INSERT INTO public.pola_perulangan VALUES (404, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 404);
INSERT INTO public.pola_perulangan VALUES (405, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 405);
INSERT INTO public.pola_perulangan VALUES (406, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 406);
INSERT INTO public.pola_perulangan VALUES (407, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 407);
INSERT INTO public.pola_perulangan VALUES (408, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 408);
INSERT INTO public.pola_perulangan VALUES (409, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 409);
INSERT INTO public.pola_perulangan VALUES (410, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 410);
INSERT INTO public.pola_perulangan VALUES (411, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 411);
INSERT INTO public.pola_perulangan VALUES (412, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 412);
INSERT INTO public.pola_perulangan VALUES (413, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 413);
INSERT INTO public.pola_perulangan VALUES (414, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 414);
INSERT INTO public.pola_perulangan VALUES (415, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 415);
INSERT INTO public.pola_perulangan VALUES (416, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 416);
INSERT INTO public.pola_perulangan VALUES (417, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 417);
INSERT INTO public.pola_perulangan VALUES (418, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 418);
INSERT INTO public.pola_perulangan VALUES (419, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 419);
INSERT INTO public.pola_perulangan VALUES (420, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 420);
INSERT INTO public.pola_perulangan VALUES (421, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 421);
INSERT INTO public.pola_perulangan VALUES (422, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 422);
INSERT INTO public.pola_perulangan VALUES (423, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 423);
INSERT INTO public.pola_perulangan VALUES (424, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 424);
INSERT INTO public.pola_perulangan VALUES (425, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 425);
INSERT INTO public.pola_perulangan VALUES (426, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 426);
INSERT INTO public.pola_perulangan VALUES (427, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:57', '2020-09-03 14:17:57', 427);
INSERT INTO public.pola_perulangan VALUES (428, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 428);
INSERT INTO public.pola_perulangan VALUES (429, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 429);
INSERT INTO public.pola_perulangan VALUES (430, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 430);
INSERT INTO public.pola_perulangan VALUES (431, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 431);
INSERT INTO public.pola_perulangan VALUES (432, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 432);
INSERT INTO public.pola_perulangan VALUES (433, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 433);
INSERT INTO public.pola_perulangan VALUES (434, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 434);
INSERT INTO public.pola_perulangan VALUES (435, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 435);
INSERT INTO public.pola_perulangan VALUES (436, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 436);
INSERT INTO public.pola_perulangan VALUES (437, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 437);
INSERT INTO public.pola_perulangan VALUES (438, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 438);
INSERT INTO public.pola_perulangan VALUES (439, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 439);
INSERT INTO public.pola_perulangan VALUES (440, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 440);
INSERT INTO public.pola_perulangan VALUES (441, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 441);
INSERT INTO public.pola_perulangan VALUES (442, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 442);
INSERT INTO public.pola_perulangan VALUES (443, 1, 1, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 443);
INSERT INTO public.pola_perulangan VALUES (444, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 444);
INSERT INTO public.pola_perulangan VALUES (445, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 445);
INSERT INTO public.pola_perulangan VALUES (446, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 446);
INSERT INTO public.pola_perulangan VALUES (447, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 447);
INSERT INTO public.pola_perulangan VALUES (448, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 448);
INSERT INTO public.pola_perulangan VALUES (449, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 449);
INSERT INTO public.pola_perulangan VALUES (450, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 450);
INSERT INTO public.pola_perulangan VALUES (451, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 451);
INSERT INTO public.pola_perulangan VALUES (452, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 452);
INSERT INTO public.pola_perulangan VALUES (453, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 453);
INSERT INTO public.pola_perulangan VALUES (454, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 454);
INSERT INTO public.pola_perulangan VALUES (455, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 455);
INSERT INTO public.pola_perulangan VALUES (456, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 456);
INSERT INTO public.pola_perulangan VALUES (457, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 457);
INSERT INTO public.pola_perulangan VALUES (458, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 458);
INSERT INTO public.pola_perulangan VALUES (459, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 459);
INSERT INTO public.pola_perulangan VALUES (460, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 460);
INSERT INTO public.pola_perulangan VALUES (461, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 461);
INSERT INTO public.pola_perulangan VALUES (462, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 462);
INSERT INTO public.pola_perulangan VALUES (463, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 463);
INSERT INTO public.pola_perulangan VALUES (464, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 464);
INSERT INTO public.pola_perulangan VALUES (465, 1, 2, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 465);
INSERT INTO public.pola_perulangan VALUES (466, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 466);
INSERT INTO public.pola_perulangan VALUES (467, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 467);
INSERT INTO public.pola_perulangan VALUES (468, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 468);
INSERT INTO public.pola_perulangan VALUES (469, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 469);
INSERT INTO public.pola_perulangan VALUES (470, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 470);
INSERT INTO public.pola_perulangan VALUES (471, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 471);
INSERT INTO public.pola_perulangan VALUES (472, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:58', '2020-09-03 14:17:58', 472);
INSERT INTO public.pola_perulangan VALUES (473, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 473);
INSERT INTO public.pola_perulangan VALUES (474, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 474);
INSERT INTO public.pola_perulangan VALUES (475, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 475);
INSERT INTO public.pola_perulangan VALUES (476, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 476);
INSERT INTO public.pola_perulangan VALUES (477, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 477);
INSERT INTO public.pola_perulangan VALUES (478, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 478);
INSERT INTO public.pola_perulangan VALUES (479, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 479);
INSERT INTO public.pola_perulangan VALUES (480, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 480);
INSERT INTO public.pola_perulangan VALUES (481, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 481);
INSERT INTO public.pola_perulangan VALUES (482, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 482);
INSERT INTO public.pola_perulangan VALUES (483, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 483);
INSERT INTO public.pola_perulangan VALUES (484, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 484);
INSERT INTO public.pola_perulangan VALUES (485, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 485);
INSERT INTO public.pola_perulangan VALUES (486, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 486);
INSERT INTO public.pola_perulangan VALUES (487, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 487);
INSERT INTO public.pola_perulangan VALUES (488, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 488);
INSERT INTO public.pola_perulangan VALUES (489, 1, 3, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 489);
INSERT INTO public.pola_perulangan VALUES (490, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 490);
INSERT INTO public.pola_perulangan VALUES (491, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 491);
INSERT INTO public.pola_perulangan VALUES (492, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 492);
INSERT INTO public.pola_perulangan VALUES (493, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 493);
INSERT INTO public.pola_perulangan VALUES (494, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 494);
INSERT INTO public.pola_perulangan VALUES (495, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 495);
INSERT INTO public.pola_perulangan VALUES (496, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 496);
INSERT INTO public.pola_perulangan VALUES (497, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 497);
INSERT INTO public.pola_perulangan VALUES (498, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 498);
INSERT INTO public.pola_perulangan VALUES (499, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 499);
INSERT INTO public.pola_perulangan VALUES (500, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 500);
INSERT INTO public.pola_perulangan VALUES (501, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 501);
INSERT INTO public.pola_perulangan VALUES (502, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 502);
INSERT INTO public.pola_perulangan VALUES (503, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 503);
INSERT INTO public.pola_perulangan VALUES (504, 1, 4, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 504);
INSERT INTO public.pola_perulangan VALUES (505, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 505);
INSERT INTO public.pola_perulangan VALUES (506, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 506);
INSERT INTO public.pola_perulangan VALUES (507, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 507);
INSERT INTO public.pola_perulangan VALUES (508, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 508);
INSERT INTO public.pola_perulangan VALUES (509, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 509);
INSERT INTO public.pola_perulangan VALUES (510, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 510);
INSERT INTO public.pola_perulangan VALUES (511, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 511);
INSERT INTO public.pola_perulangan VALUES (512, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 512);
INSERT INTO public.pola_perulangan VALUES (513, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 513);
INSERT INTO public.pola_perulangan VALUES (514, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 514);
INSERT INTO public.pola_perulangan VALUES (515, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 515);
INSERT INTO public.pola_perulangan VALUES (516, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 516);
INSERT INTO public.pola_perulangan VALUES (517, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 517);
INSERT INTO public.pola_perulangan VALUES (518, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 518);
INSERT INTO public.pola_perulangan VALUES (519, 1, 5, NULL, NULL, NULL, '2020-09-03 14:17:59', '2020-09-03 14:17:59', 519);
INSERT INTO public.pola_perulangan VALUES (520, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 520);
INSERT INTO public.pola_perulangan VALUES (521, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 521);
INSERT INTO public.pola_perulangan VALUES (522, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 522);
INSERT INTO public.pola_perulangan VALUES (523, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 523);
INSERT INTO public.pola_perulangan VALUES (524, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 524);
INSERT INTO public.pola_perulangan VALUES (525, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 525);
INSERT INTO public.pola_perulangan VALUES (526, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 526);
INSERT INTO public.pola_perulangan VALUES (527, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 527);
INSERT INTO public.pola_perulangan VALUES (528, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 528);
INSERT INTO public.pola_perulangan VALUES (529, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 529);
INSERT INTO public.pola_perulangan VALUES (530, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 530);
INSERT INTO public.pola_perulangan VALUES (531, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 531);
INSERT INTO public.pola_perulangan VALUES (532, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 532);
INSERT INTO public.pola_perulangan VALUES (533, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 533);
INSERT INTO public.pola_perulangan VALUES (534, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 534);
INSERT INTO public.pola_perulangan VALUES (535, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 535);
INSERT INTO public.pola_perulangan VALUES (536, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 536);
INSERT INTO public.pola_perulangan VALUES (537, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 537);
INSERT INTO public.pola_perulangan VALUES (538, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 538);
INSERT INTO public.pola_perulangan VALUES (539, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 539);
INSERT INTO public.pola_perulangan VALUES (540, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 540);
INSERT INTO public.pola_perulangan VALUES (541, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 541);
INSERT INTO public.pola_perulangan VALUES (542, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 542);
INSERT INTO public.pola_perulangan VALUES (543, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 543);
INSERT INTO public.pola_perulangan VALUES (544, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 544);
INSERT INTO public.pola_perulangan VALUES (545, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 545);
INSERT INTO public.pola_perulangan VALUES (546, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 546);
INSERT INTO public.pola_perulangan VALUES (547, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 547);
INSERT INTO public.pola_perulangan VALUES (548, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 548);
INSERT INTO public.pola_perulangan VALUES (549, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 549);
INSERT INTO public.pola_perulangan VALUES (550, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 550);
INSERT INTO public.pola_perulangan VALUES (551, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 551);
INSERT INTO public.pola_perulangan VALUES (552, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 552);
INSERT INTO public.pola_perulangan VALUES (553, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 553);
INSERT INTO public.pola_perulangan VALUES (554, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 554);
INSERT INTO public.pola_perulangan VALUES (555, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 555);
INSERT INTO public.pola_perulangan VALUES (556, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 556);
INSERT INTO public.pola_perulangan VALUES (557, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 557);
INSERT INTO public.pola_perulangan VALUES (558, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 558);
INSERT INTO public.pola_perulangan VALUES (559, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 559);
INSERT INTO public.pola_perulangan VALUES (560, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 560);
INSERT INTO public.pola_perulangan VALUES (561, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 561);
INSERT INTO public.pola_perulangan VALUES (562, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 562);
INSERT INTO public.pola_perulangan VALUES (563, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 563);
INSERT INTO public.pola_perulangan VALUES (564, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 564);
INSERT INTO public.pola_perulangan VALUES (565, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:00', '2020-09-03 14:18:00', 565);
INSERT INTO public.pola_perulangan VALUES (566, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 566);
INSERT INTO public.pola_perulangan VALUES (567, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 567);
INSERT INTO public.pola_perulangan VALUES (568, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 568);
INSERT INTO public.pola_perulangan VALUES (569, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 569);
INSERT INTO public.pola_perulangan VALUES (570, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 570);
INSERT INTO public.pola_perulangan VALUES (571, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 571);
INSERT INTO public.pola_perulangan VALUES (572, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 572);
INSERT INTO public.pola_perulangan VALUES (573, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 573);
INSERT INTO public.pola_perulangan VALUES (574, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 574);
INSERT INTO public.pola_perulangan VALUES (575, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 575);
INSERT INTO public.pola_perulangan VALUES (576, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 576);
INSERT INTO public.pola_perulangan VALUES (577, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 577);
INSERT INTO public.pola_perulangan VALUES (578, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 578);
INSERT INTO public.pola_perulangan VALUES (579, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 579);
INSERT INTO public.pola_perulangan VALUES (580, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 580);
INSERT INTO public.pola_perulangan VALUES (581, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 581);
INSERT INTO public.pola_perulangan VALUES (582, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 582);
INSERT INTO public.pola_perulangan VALUES (583, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 583);
INSERT INTO public.pola_perulangan VALUES (584, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 584);
INSERT INTO public.pola_perulangan VALUES (585, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 585);
INSERT INTO public.pola_perulangan VALUES (586, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 586);
INSERT INTO public.pola_perulangan VALUES (587, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 587);
INSERT INTO public.pola_perulangan VALUES (588, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 588);
INSERT INTO public.pola_perulangan VALUES (589, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 589);
INSERT INTO public.pola_perulangan VALUES (590, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 590);
INSERT INTO public.pola_perulangan VALUES (591, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 591);
INSERT INTO public.pola_perulangan VALUES (592, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 592);
INSERT INTO public.pola_perulangan VALUES (593, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 593);
INSERT INTO public.pola_perulangan VALUES (594, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 594);
INSERT INTO public.pola_perulangan VALUES (595, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 595);
INSERT INTO public.pola_perulangan VALUES (596, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 596);
INSERT INTO public.pola_perulangan VALUES (597, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 597);
INSERT INTO public.pola_perulangan VALUES (598, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 598);
INSERT INTO public.pola_perulangan VALUES (599, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 599);
INSERT INTO public.pola_perulangan VALUES (600, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 600);
INSERT INTO public.pola_perulangan VALUES (601, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 601);
INSERT INTO public.pola_perulangan VALUES (602, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 602);
INSERT INTO public.pola_perulangan VALUES (603, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 603);
INSERT INTO public.pola_perulangan VALUES (604, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 604);
INSERT INTO public.pola_perulangan VALUES (605, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 605);
INSERT INTO public.pola_perulangan VALUES (606, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 606);
INSERT INTO public.pola_perulangan VALUES (607, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 607);
INSERT INTO public.pola_perulangan VALUES (608, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 608);
INSERT INTO public.pola_perulangan VALUES (609, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 609);
INSERT INTO public.pola_perulangan VALUES (610, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 610);
INSERT INTO public.pola_perulangan VALUES (611, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 611);
INSERT INTO public.pola_perulangan VALUES (612, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 612);
INSERT INTO public.pola_perulangan VALUES (613, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 613);
INSERT INTO public.pola_perulangan VALUES (614, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 614);
INSERT INTO public.pola_perulangan VALUES (615, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 615);
INSERT INTO public.pola_perulangan VALUES (616, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:01', '2020-09-03 14:18:01', 616);
INSERT INTO public.pola_perulangan VALUES (617, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 617);
INSERT INTO public.pola_perulangan VALUES (618, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 618);
INSERT INTO public.pola_perulangan VALUES (619, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 619);
INSERT INTO public.pola_perulangan VALUES (620, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 620);
INSERT INTO public.pola_perulangan VALUES (621, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 621);
INSERT INTO public.pola_perulangan VALUES (622, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 622);
INSERT INTO public.pola_perulangan VALUES (623, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 623);
INSERT INTO public.pola_perulangan VALUES (624, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 624);
INSERT INTO public.pola_perulangan VALUES (625, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 625);
INSERT INTO public.pola_perulangan VALUES (626, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 626);
INSERT INTO public.pola_perulangan VALUES (627, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 627);
INSERT INTO public.pola_perulangan VALUES (628, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 628);
INSERT INTO public.pola_perulangan VALUES (629, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 629);
INSERT INTO public.pola_perulangan VALUES (630, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 630);
INSERT INTO public.pola_perulangan VALUES (631, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 631);
INSERT INTO public.pola_perulangan VALUES (632, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 632);
INSERT INTO public.pola_perulangan VALUES (633, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 633);
INSERT INTO public.pola_perulangan VALUES (634, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 634);
INSERT INTO public.pola_perulangan VALUES (635, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 635);
INSERT INTO public.pola_perulangan VALUES (636, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 636);
INSERT INTO public.pola_perulangan VALUES (637, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 637);
INSERT INTO public.pola_perulangan VALUES (638, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 638);
INSERT INTO public.pola_perulangan VALUES (639, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 639);
INSERT INTO public.pola_perulangan VALUES (640, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 640);
INSERT INTO public.pola_perulangan VALUES (641, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 641);
INSERT INTO public.pola_perulangan VALUES (642, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 642);
INSERT INTO public.pola_perulangan VALUES (643, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 643);
INSERT INTO public.pola_perulangan VALUES (644, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 644);
INSERT INTO public.pola_perulangan VALUES (645, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 645);
INSERT INTO public.pola_perulangan VALUES (646, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 646);
INSERT INTO public.pola_perulangan VALUES (647, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 647);
INSERT INTO public.pola_perulangan VALUES (648, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 648);
INSERT INTO public.pola_perulangan VALUES (649, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 649);
INSERT INTO public.pola_perulangan VALUES (650, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 650);
INSERT INTO public.pola_perulangan VALUES (651, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 651);
INSERT INTO public.pola_perulangan VALUES (652, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 652);
INSERT INTO public.pola_perulangan VALUES (653, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 653);
INSERT INTO public.pola_perulangan VALUES (654, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 654);
INSERT INTO public.pola_perulangan VALUES (655, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 655);
INSERT INTO public.pola_perulangan VALUES (656, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 656);
INSERT INTO public.pola_perulangan VALUES (657, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 657);
INSERT INTO public.pola_perulangan VALUES (658, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 658);
INSERT INTO public.pola_perulangan VALUES (659, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 659);
INSERT INTO public.pola_perulangan VALUES (660, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:02', '2020-09-03 14:18:02', 660);
INSERT INTO public.pola_perulangan VALUES (661, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 661);
INSERT INTO public.pola_perulangan VALUES (662, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 662);
INSERT INTO public.pola_perulangan VALUES (663, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 663);
INSERT INTO public.pola_perulangan VALUES (664, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 664);
INSERT INTO public.pola_perulangan VALUES (665, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 665);
INSERT INTO public.pola_perulangan VALUES (666, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 666);
INSERT INTO public.pola_perulangan VALUES (667, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 667);
INSERT INTO public.pola_perulangan VALUES (668, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 668);
INSERT INTO public.pola_perulangan VALUES (669, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 669);
INSERT INTO public.pola_perulangan VALUES (670, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 670);
INSERT INTO public.pola_perulangan VALUES (671, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 671);
INSERT INTO public.pola_perulangan VALUES (672, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 672);
INSERT INTO public.pola_perulangan VALUES (673, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 673);
INSERT INTO public.pola_perulangan VALUES (674, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 674);
INSERT INTO public.pola_perulangan VALUES (675, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 675);
INSERT INTO public.pola_perulangan VALUES (676, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 676);
INSERT INTO public.pola_perulangan VALUES (677, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 677);
INSERT INTO public.pola_perulangan VALUES (678, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 678);
INSERT INTO public.pola_perulangan VALUES (679, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 679);
INSERT INTO public.pola_perulangan VALUES (680, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 680);
INSERT INTO public.pola_perulangan VALUES (681, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 681);
INSERT INTO public.pola_perulangan VALUES (682, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 682);
INSERT INTO public.pola_perulangan VALUES (683, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 683);
INSERT INTO public.pola_perulangan VALUES (684, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 684);
INSERT INTO public.pola_perulangan VALUES (685, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 685);
INSERT INTO public.pola_perulangan VALUES (686, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 686);
INSERT INTO public.pola_perulangan VALUES (687, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 687);
INSERT INTO public.pola_perulangan VALUES (688, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 688);
INSERT INTO public.pola_perulangan VALUES (689, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 689);
INSERT INTO public.pola_perulangan VALUES (690, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 690);
INSERT INTO public.pola_perulangan VALUES (691, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 691);
INSERT INTO public.pola_perulangan VALUES (692, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 692);
INSERT INTO public.pola_perulangan VALUES (693, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 693);
INSERT INTO public.pola_perulangan VALUES (694, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 694);
INSERT INTO public.pola_perulangan VALUES (695, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 695);
INSERT INTO public.pola_perulangan VALUES (696, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 696);
INSERT INTO public.pola_perulangan VALUES (697, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 697);
INSERT INTO public.pola_perulangan VALUES (698, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 698);
INSERT INTO public.pola_perulangan VALUES (699, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 699);
INSERT INTO public.pola_perulangan VALUES (700, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 700);
INSERT INTO public.pola_perulangan VALUES (701, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 701);
INSERT INTO public.pola_perulangan VALUES (702, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 702);
INSERT INTO public.pola_perulangan VALUES (703, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 703);
INSERT INTO public.pola_perulangan VALUES (704, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 704);
INSERT INTO public.pola_perulangan VALUES (705, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 705);
INSERT INTO public.pola_perulangan VALUES (706, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 706);
INSERT INTO public.pola_perulangan VALUES (707, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 707);
INSERT INTO public.pola_perulangan VALUES (708, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 708);
INSERT INTO public.pola_perulangan VALUES (709, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 709);
INSERT INTO public.pola_perulangan VALUES (710, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 710);
INSERT INTO public.pola_perulangan VALUES (711, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 711);
INSERT INTO public.pola_perulangan VALUES (712, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 712);
INSERT INTO public.pola_perulangan VALUES (713, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 713);
INSERT INTO public.pola_perulangan VALUES (714, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 714);
INSERT INTO public.pola_perulangan VALUES (715, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 715);
INSERT INTO public.pola_perulangan VALUES (716, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:03', '2020-09-03 14:18:03', 716);
INSERT INTO public.pola_perulangan VALUES (717, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 717);
INSERT INTO public.pola_perulangan VALUES (718, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 718);
INSERT INTO public.pola_perulangan VALUES (719, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 719);
INSERT INTO public.pola_perulangan VALUES (720, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 720);
INSERT INTO public.pola_perulangan VALUES (721, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 721);
INSERT INTO public.pola_perulangan VALUES (722, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 722);
INSERT INTO public.pola_perulangan VALUES (723, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 723);
INSERT INTO public.pola_perulangan VALUES (724, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 724);
INSERT INTO public.pola_perulangan VALUES (725, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 725);
INSERT INTO public.pola_perulangan VALUES (726, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 726);
INSERT INTO public.pola_perulangan VALUES (727, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 727);
INSERT INTO public.pola_perulangan VALUES (728, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 728);
INSERT INTO public.pola_perulangan VALUES (729, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 729);
INSERT INTO public.pola_perulangan VALUES (730, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 730);
INSERT INTO public.pola_perulangan VALUES (731, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 731);
INSERT INTO public.pola_perulangan VALUES (732, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 732);
INSERT INTO public.pola_perulangan VALUES (733, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 733);
INSERT INTO public.pola_perulangan VALUES (734, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 734);
INSERT INTO public.pola_perulangan VALUES (735, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 735);
INSERT INTO public.pola_perulangan VALUES (736, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 736);
INSERT INTO public.pola_perulangan VALUES (737, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 737);
INSERT INTO public.pola_perulangan VALUES (738, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 738);
INSERT INTO public.pola_perulangan VALUES (739, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 739);
INSERT INTO public.pola_perulangan VALUES (740, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 740);
INSERT INTO public.pola_perulangan VALUES (741, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 741);
INSERT INTO public.pola_perulangan VALUES (742, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 742);
INSERT INTO public.pola_perulangan VALUES (743, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 743);
INSERT INTO public.pola_perulangan VALUES (744, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 744);
INSERT INTO public.pola_perulangan VALUES (745, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 745);
INSERT INTO public.pola_perulangan VALUES (746, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 746);
INSERT INTO public.pola_perulangan VALUES (747, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 747);
INSERT INTO public.pola_perulangan VALUES (748, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 748);
INSERT INTO public.pola_perulangan VALUES (749, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 749);
INSERT INTO public.pola_perulangan VALUES (750, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 750);
INSERT INTO public.pola_perulangan VALUES (751, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 751);
INSERT INTO public.pola_perulangan VALUES (752, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 752);
INSERT INTO public.pola_perulangan VALUES (753, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 753);
INSERT INTO public.pola_perulangan VALUES (754, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 754);
INSERT INTO public.pola_perulangan VALUES (755, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 755);
INSERT INTO public.pola_perulangan VALUES (756, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 756);
INSERT INTO public.pola_perulangan VALUES (757, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 757);
INSERT INTO public.pola_perulangan VALUES (758, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 758);
INSERT INTO public.pola_perulangan VALUES (759, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 759);
INSERT INTO public.pola_perulangan VALUES (760, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 760);
INSERT INTO public.pola_perulangan VALUES (761, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 761);
INSERT INTO public.pola_perulangan VALUES (762, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 762);
INSERT INTO public.pola_perulangan VALUES (763, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 763);
INSERT INTO public.pola_perulangan VALUES (764, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 764);
INSERT INTO public.pola_perulangan VALUES (765, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 765);
INSERT INTO public.pola_perulangan VALUES (766, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 766);
INSERT INTO public.pola_perulangan VALUES (767, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 767);
INSERT INTO public.pola_perulangan VALUES (768, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 768);
INSERT INTO public.pola_perulangan VALUES (769, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 769);
INSERT INTO public.pola_perulangan VALUES (770, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 770);
INSERT INTO public.pola_perulangan VALUES (771, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 771);
INSERT INTO public.pola_perulangan VALUES (772, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 772);
INSERT INTO public.pola_perulangan VALUES (773, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 773);
INSERT INTO public.pola_perulangan VALUES (774, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:04', '2020-09-03 14:18:04', 774);
INSERT INTO public.pola_perulangan VALUES (775, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 775);
INSERT INTO public.pola_perulangan VALUES (776, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 776);
INSERT INTO public.pola_perulangan VALUES (777, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 777);
INSERT INTO public.pola_perulangan VALUES (778, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 778);
INSERT INTO public.pola_perulangan VALUES (779, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 779);
INSERT INTO public.pola_perulangan VALUES (780, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 780);
INSERT INTO public.pola_perulangan VALUES (781, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 781);
INSERT INTO public.pola_perulangan VALUES (782, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 782);
INSERT INTO public.pola_perulangan VALUES (783, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 783);
INSERT INTO public.pola_perulangan VALUES (784, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 784);
INSERT INTO public.pola_perulangan VALUES (785, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 785);
INSERT INTO public.pola_perulangan VALUES (786, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 786);
INSERT INTO public.pola_perulangan VALUES (787, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 787);
INSERT INTO public.pola_perulangan VALUES (788, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 788);
INSERT INTO public.pola_perulangan VALUES (789, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 789);
INSERT INTO public.pola_perulangan VALUES (790, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 790);
INSERT INTO public.pola_perulangan VALUES (791, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 791);
INSERT INTO public.pola_perulangan VALUES (792, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 792);
INSERT INTO public.pola_perulangan VALUES (793, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 793);
INSERT INTO public.pola_perulangan VALUES (794, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 794);
INSERT INTO public.pola_perulangan VALUES (795, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 795);
INSERT INTO public.pola_perulangan VALUES (796, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 796);
INSERT INTO public.pola_perulangan VALUES (797, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 797);
INSERT INTO public.pola_perulangan VALUES (798, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 798);
INSERT INTO public.pola_perulangan VALUES (799, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 799);
INSERT INTO public.pola_perulangan VALUES (800, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 800);
INSERT INTO public.pola_perulangan VALUES (801, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 801);
INSERT INTO public.pola_perulangan VALUES (802, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 802);
INSERT INTO public.pola_perulangan VALUES (803, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 803);
INSERT INTO public.pola_perulangan VALUES (804, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 804);
INSERT INTO public.pola_perulangan VALUES (805, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 805);
INSERT INTO public.pola_perulangan VALUES (806, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 806);
INSERT INTO public.pola_perulangan VALUES (807, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 807);
INSERT INTO public.pola_perulangan VALUES (808, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 808);
INSERT INTO public.pola_perulangan VALUES (809, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 809);
INSERT INTO public.pola_perulangan VALUES (810, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 810);
INSERT INTO public.pola_perulangan VALUES (811, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 811);
INSERT INTO public.pola_perulangan VALUES (812, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 812);
INSERT INTO public.pola_perulangan VALUES (813, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 813);
INSERT INTO public.pola_perulangan VALUES (814, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 814);
INSERT INTO public.pola_perulangan VALUES (815, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 815);
INSERT INTO public.pola_perulangan VALUES (816, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 816);
INSERT INTO public.pola_perulangan VALUES (817, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 817);
INSERT INTO public.pola_perulangan VALUES (818, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 818);
INSERT INTO public.pola_perulangan VALUES (819, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 819);
INSERT INTO public.pola_perulangan VALUES (820, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 820);
INSERT INTO public.pola_perulangan VALUES (821, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 821);
INSERT INTO public.pola_perulangan VALUES (822, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 822);
INSERT INTO public.pola_perulangan VALUES (823, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 823);
INSERT INTO public.pola_perulangan VALUES (824, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 824);
INSERT INTO public.pola_perulangan VALUES (825, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 825);
INSERT INTO public.pola_perulangan VALUES (826, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 826);
INSERT INTO public.pola_perulangan VALUES (827, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 827);
INSERT INTO public.pola_perulangan VALUES (828, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 828);
INSERT INTO public.pola_perulangan VALUES (829, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 829);
INSERT INTO public.pola_perulangan VALUES (830, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 830);
INSERT INTO public.pola_perulangan VALUES (831, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 831);
INSERT INTO public.pola_perulangan VALUES (832, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 832);
INSERT INTO public.pola_perulangan VALUES (833, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 833);
INSERT INTO public.pola_perulangan VALUES (834, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 834);
INSERT INTO public.pola_perulangan VALUES (835, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 835);
INSERT INTO public.pola_perulangan VALUES (836, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 836);
INSERT INTO public.pola_perulangan VALUES (837, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 837);
INSERT INTO public.pola_perulangan VALUES (838, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:05', '2020-09-03 14:18:05', 838);
INSERT INTO public.pola_perulangan VALUES (839, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 839);
INSERT INTO public.pola_perulangan VALUES (840, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 840);
INSERT INTO public.pola_perulangan VALUES (841, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 841);
INSERT INTO public.pola_perulangan VALUES (842, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 842);
INSERT INTO public.pola_perulangan VALUES (843, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 843);
INSERT INTO public.pola_perulangan VALUES (844, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 844);
INSERT INTO public.pola_perulangan VALUES (845, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 845);
INSERT INTO public.pola_perulangan VALUES (846, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 846);
INSERT INTO public.pola_perulangan VALUES (847, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 847);
INSERT INTO public.pola_perulangan VALUES (848, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 848);
INSERT INTO public.pola_perulangan VALUES (849, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 849);
INSERT INTO public.pola_perulangan VALUES (850, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 850);
INSERT INTO public.pola_perulangan VALUES (851, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 851);
INSERT INTO public.pola_perulangan VALUES (852, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 852);
INSERT INTO public.pola_perulangan VALUES (853, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 853);
INSERT INTO public.pola_perulangan VALUES (854, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 854);
INSERT INTO public.pola_perulangan VALUES (855, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 855);
INSERT INTO public.pola_perulangan VALUES (856, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 856);
INSERT INTO public.pola_perulangan VALUES (857, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 857);
INSERT INTO public.pola_perulangan VALUES (858, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 858);
INSERT INTO public.pola_perulangan VALUES (859, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 859);
INSERT INTO public.pola_perulangan VALUES (860, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 860);
INSERT INTO public.pola_perulangan VALUES (861, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 861);
INSERT INTO public.pola_perulangan VALUES (862, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 862);
INSERT INTO public.pola_perulangan VALUES (863, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 863);
INSERT INTO public.pola_perulangan VALUES (864, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 864);
INSERT INTO public.pola_perulangan VALUES (865, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 865);
INSERT INTO public.pola_perulangan VALUES (866, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 866);
INSERT INTO public.pola_perulangan VALUES (867, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 867);
INSERT INTO public.pola_perulangan VALUES (868, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 868);
INSERT INTO public.pola_perulangan VALUES (869, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 869);
INSERT INTO public.pola_perulangan VALUES (870, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 870);
INSERT INTO public.pola_perulangan VALUES (871, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 871);
INSERT INTO public.pola_perulangan VALUES (872, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 872);
INSERT INTO public.pola_perulangan VALUES (873, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 873);
INSERT INTO public.pola_perulangan VALUES (874, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 874);
INSERT INTO public.pola_perulangan VALUES (875, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 875);
INSERT INTO public.pola_perulangan VALUES (876, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 876);
INSERT INTO public.pola_perulangan VALUES (877, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 877);
INSERT INTO public.pola_perulangan VALUES (878, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 878);
INSERT INTO public.pola_perulangan VALUES (879, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 879);
INSERT INTO public.pola_perulangan VALUES (880, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 880);
INSERT INTO public.pola_perulangan VALUES (881, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 881);
INSERT INTO public.pola_perulangan VALUES (882, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 882);
INSERT INTO public.pola_perulangan VALUES (883, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 883);
INSERT INTO public.pola_perulangan VALUES (884, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 884);
INSERT INTO public.pola_perulangan VALUES (885, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 885);
INSERT INTO public.pola_perulangan VALUES (886, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 886);
INSERT INTO public.pola_perulangan VALUES (887, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 887);
INSERT INTO public.pola_perulangan VALUES (888, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 888);
INSERT INTO public.pola_perulangan VALUES (889, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 889);
INSERT INTO public.pola_perulangan VALUES (890, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 890);
INSERT INTO public.pola_perulangan VALUES (891, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 891);
INSERT INTO public.pola_perulangan VALUES (892, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 892);
INSERT INTO public.pola_perulangan VALUES (893, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 893);
INSERT INTO public.pola_perulangan VALUES (894, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 894);
INSERT INTO public.pola_perulangan VALUES (895, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 895);
INSERT INTO public.pola_perulangan VALUES (896, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:06', '2020-09-03 14:18:06', 896);
INSERT INTO public.pola_perulangan VALUES (897, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 897);
INSERT INTO public.pola_perulangan VALUES (898, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 898);
INSERT INTO public.pola_perulangan VALUES (899, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 899);
INSERT INTO public.pola_perulangan VALUES (900, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 900);
INSERT INTO public.pola_perulangan VALUES (901, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 901);
INSERT INTO public.pola_perulangan VALUES (902, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 902);
INSERT INTO public.pola_perulangan VALUES (903, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 903);
INSERT INTO public.pola_perulangan VALUES (904, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 904);
INSERT INTO public.pola_perulangan VALUES (905, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 905);
INSERT INTO public.pola_perulangan VALUES (906, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 906);
INSERT INTO public.pola_perulangan VALUES (907, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 907);
INSERT INTO public.pola_perulangan VALUES (908, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 908);
INSERT INTO public.pola_perulangan VALUES (909, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 909);
INSERT INTO public.pola_perulangan VALUES (910, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 910);
INSERT INTO public.pola_perulangan VALUES (911, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 911);
INSERT INTO public.pola_perulangan VALUES (912, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 912);
INSERT INTO public.pola_perulangan VALUES (913, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 913);
INSERT INTO public.pola_perulangan VALUES (914, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 914);
INSERT INTO public.pola_perulangan VALUES (915, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 915);
INSERT INTO public.pola_perulangan VALUES (916, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 916);
INSERT INTO public.pola_perulangan VALUES (917, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 917);
INSERT INTO public.pola_perulangan VALUES (918, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 918);
INSERT INTO public.pola_perulangan VALUES (919, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 919);
INSERT INTO public.pola_perulangan VALUES (920, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 920);
INSERT INTO public.pola_perulangan VALUES (921, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 921);
INSERT INTO public.pola_perulangan VALUES (922, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 922);
INSERT INTO public.pola_perulangan VALUES (923, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 923);
INSERT INTO public.pola_perulangan VALUES (924, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 924);
INSERT INTO public.pola_perulangan VALUES (925, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 925);
INSERT INTO public.pola_perulangan VALUES (926, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 926);
INSERT INTO public.pola_perulangan VALUES (927, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 927);
INSERT INTO public.pola_perulangan VALUES (928, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 928);
INSERT INTO public.pola_perulangan VALUES (929, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 929);
INSERT INTO public.pola_perulangan VALUES (930, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 930);
INSERT INTO public.pola_perulangan VALUES (931, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 931);
INSERT INTO public.pola_perulangan VALUES (932, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 932);
INSERT INTO public.pola_perulangan VALUES (933, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 933);
INSERT INTO public.pola_perulangan VALUES (934, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 934);
INSERT INTO public.pola_perulangan VALUES (935, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 935);
INSERT INTO public.pola_perulangan VALUES (936, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 936);
INSERT INTO public.pola_perulangan VALUES (937, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 937);
INSERT INTO public.pola_perulangan VALUES (938, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 938);
INSERT INTO public.pola_perulangan VALUES (939, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 939);
INSERT INTO public.pola_perulangan VALUES (940, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 940);
INSERT INTO public.pola_perulangan VALUES (941, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 941);
INSERT INTO public.pola_perulangan VALUES (942, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 942);
INSERT INTO public.pola_perulangan VALUES (943, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 943);
INSERT INTO public.pola_perulangan VALUES (944, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 944);
INSERT INTO public.pola_perulangan VALUES (945, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 945);
INSERT INTO public.pola_perulangan VALUES (946, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 946);
INSERT INTO public.pola_perulangan VALUES (947, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 947);
INSERT INTO public.pola_perulangan VALUES (948, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 948);
INSERT INTO public.pola_perulangan VALUES (949, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 949);
INSERT INTO public.pola_perulangan VALUES (950, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 950);
INSERT INTO public.pola_perulangan VALUES (951, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 951);
INSERT INTO public.pola_perulangan VALUES (952, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 952);
INSERT INTO public.pola_perulangan VALUES (953, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 953);
INSERT INTO public.pola_perulangan VALUES (954, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 954);
INSERT INTO public.pola_perulangan VALUES (955, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 955);
INSERT INTO public.pola_perulangan VALUES (956, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 956);
INSERT INTO public.pola_perulangan VALUES (957, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 957);
INSERT INTO public.pola_perulangan VALUES (958, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:07', '2020-09-03 14:18:07', 958);
INSERT INTO public.pola_perulangan VALUES (959, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 959);
INSERT INTO public.pola_perulangan VALUES (960, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 960);
INSERT INTO public.pola_perulangan VALUES (961, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 961);
INSERT INTO public.pola_perulangan VALUES (962, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 962);
INSERT INTO public.pola_perulangan VALUES (963, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 963);
INSERT INTO public.pola_perulangan VALUES (964, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 964);
INSERT INTO public.pola_perulangan VALUES (965, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 965);
INSERT INTO public.pola_perulangan VALUES (966, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 966);
INSERT INTO public.pola_perulangan VALUES (967, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 967);
INSERT INTO public.pola_perulangan VALUES (968, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 968);
INSERT INTO public.pola_perulangan VALUES (969, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 969);
INSERT INTO public.pola_perulangan VALUES (970, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 970);
INSERT INTO public.pola_perulangan VALUES (971, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 971);
INSERT INTO public.pola_perulangan VALUES (972, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 972);
INSERT INTO public.pola_perulangan VALUES (973, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 973);
INSERT INTO public.pola_perulangan VALUES (974, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 974);
INSERT INTO public.pola_perulangan VALUES (975, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 975);
INSERT INTO public.pola_perulangan VALUES (976, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 976);
INSERT INTO public.pola_perulangan VALUES (977, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 977);
INSERT INTO public.pola_perulangan VALUES (978, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 978);
INSERT INTO public.pola_perulangan VALUES (979, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 979);
INSERT INTO public.pola_perulangan VALUES (980, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 980);
INSERT INTO public.pola_perulangan VALUES (981, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 981);
INSERT INTO public.pola_perulangan VALUES (982, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 982);
INSERT INTO public.pola_perulangan VALUES (983, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 983);
INSERT INTO public.pola_perulangan VALUES (984, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 984);
INSERT INTO public.pola_perulangan VALUES (985, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 985);
INSERT INTO public.pola_perulangan VALUES (986, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 986);
INSERT INTO public.pola_perulangan VALUES (987, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 987);
INSERT INTO public.pola_perulangan VALUES (988, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 988);
INSERT INTO public.pola_perulangan VALUES (989, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 989);
INSERT INTO public.pola_perulangan VALUES (990, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 990);
INSERT INTO public.pola_perulangan VALUES (991, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 991);
INSERT INTO public.pola_perulangan VALUES (992, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 992);
INSERT INTO public.pola_perulangan VALUES (993, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 993);
INSERT INTO public.pola_perulangan VALUES (994, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 994);
INSERT INTO public.pola_perulangan VALUES (995, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 995);
INSERT INTO public.pola_perulangan VALUES (996, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 996);
INSERT INTO public.pola_perulangan VALUES (997, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 997);
INSERT INTO public.pola_perulangan VALUES (998, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 998);
INSERT INTO public.pola_perulangan VALUES (999, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 999);
INSERT INTO public.pola_perulangan VALUES (1000, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 1000);
INSERT INTO public.pola_perulangan VALUES (1001, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 1001);
INSERT INTO public.pola_perulangan VALUES (1002, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:08', '2020-09-03 14:18:08', 1002);
INSERT INTO public.pola_perulangan VALUES (1003, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1003);
INSERT INTO public.pola_perulangan VALUES (1004, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1004);
INSERT INTO public.pola_perulangan VALUES (1005, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1005);
INSERT INTO public.pola_perulangan VALUES (1006, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1006);
INSERT INTO public.pola_perulangan VALUES (1007, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1007);
INSERT INTO public.pola_perulangan VALUES (1008, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1008);
INSERT INTO public.pola_perulangan VALUES (1009, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1009);
INSERT INTO public.pola_perulangan VALUES (1010, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1010);
INSERT INTO public.pola_perulangan VALUES (1011, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1011);
INSERT INTO public.pola_perulangan VALUES (1012, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1012);
INSERT INTO public.pola_perulangan VALUES (1013, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1013);
INSERT INTO public.pola_perulangan VALUES (1014, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1014);
INSERT INTO public.pola_perulangan VALUES (1015, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1015);
INSERT INTO public.pola_perulangan VALUES (1016, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1016);
INSERT INTO public.pola_perulangan VALUES (1017, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1017);
INSERT INTO public.pola_perulangan VALUES (1018, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1018);
INSERT INTO public.pola_perulangan VALUES (1019, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1019);
INSERT INTO public.pola_perulangan VALUES (1020, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1020);
INSERT INTO public.pola_perulangan VALUES (1021, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1021);
INSERT INTO public.pola_perulangan VALUES (1022, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1022);
INSERT INTO public.pola_perulangan VALUES (1023, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1023);
INSERT INTO public.pola_perulangan VALUES (1024, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1024);
INSERT INTO public.pola_perulangan VALUES (1025, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1025);
INSERT INTO public.pola_perulangan VALUES (1026, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1026);
INSERT INTO public.pola_perulangan VALUES (1027, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1027);
INSERT INTO public.pola_perulangan VALUES (1028, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1028);
INSERT INTO public.pola_perulangan VALUES (1029, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1029);
INSERT INTO public.pola_perulangan VALUES (1030, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1030);
INSERT INTO public.pola_perulangan VALUES (1031, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1031);
INSERT INTO public.pola_perulangan VALUES (1032, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1032);
INSERT INTO public.pola_perulangan VALUES (1033, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:09', '2020-09-03 14:18:09', 1033);
INSERT INTO public.pola_perulangan VALUES (1034, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1034);
INSERT INTO public.pola_perulangan VALUES (1035, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1035);
INSERT INTO public.pola_perulangan VALUES (1036, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1036);
INSERT INTO public.pola_perulangan VALUES (1037, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1037);
INSERT INTO public.pola_perulangan VALUES (1038, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1038);
INSERT INTO public.pola_perulangan VALUES (1039, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1039);
INSERT INTO public.pola_perulangan VALUES (1040, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1040);
INSERT INTO public.pola_perulangan VALUES (1041, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1041);
INSERT INTO public.pola_perulangan VALUES (1042, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1042);
INSERT INTO public.pola_perulangan VALUES (1043, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1043);
INSERT INTO public.pola_perulangan VALUES (1044, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1044);
INSERT INTO public.pola_perulangan VALUES (1045, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1045);
INSERT INTO public.pola_perulangan VALUES (1046, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1046);
INSERT INTO public.pola_perulangan VALUES (1047, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1047);
INSERT INTO public.pola_perulangan VALUES (1048, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1048);
INSERT INTO public.pola_perulangan VALUES (1049, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1049);
INSERT INTO public.pola_perulangan VALUES (1050, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1050);
INSERT INTO public.pola_perulangan VALUES (1051, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1051);
INSERT INTO public.pola_perulangan VALUES (1052, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1052);
INSERT INTO public.pola_perulangan VALUES (1053, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1053);
INSERT INTO public.pola_perulangan VALUES (1054, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1054);
INSERT INTO public.pola_perulangan VALUES (1055, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1055);
INSERT INTO public.pola_perulangan VALUES (1056, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1056);
INSERT INTO public.pola_perulangan VALUES (1057, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1057);
INSERT INTO public.pola_perulangan VALUES (1058, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1058);
INSERT INTO public.pola_perulangan VALUES (1059, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1059);
INSERT INTO public.pola_perulangan VALUES (1060, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1060);
INSERT INTO public.pola_perulangan VALUES (1061, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1061);
INSERT INTO public.pola_perulangan VALUES (1062, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1062);
INSERT INTO public.pola_perulangan VALUES (1063, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1063);
INSERT INTO public.pola_perulangan VALUES (1064, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1064);
INSERT INTO public.pola_perulangan VALUES (1065, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1065);
INSERT INTO public.pola_perulangan VALUES (1066, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1066);
INSERT INTO public.pola_perulangan VALUES (1067, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1067);
INSERT INTO public.pola_perulangan VALUES (1068, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1068);
INSERT INTO public.pola_perulangan VALUES (1069, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1069);
INSERT INTO public.pola_perulangan VALUES (1070, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1070);
INSERT INTO public.pola_perulangan VALUES (1071, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1071);
INSERT INTO public.pola_perulangan VALUES (1072, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1072);
INSERT INTO public.pola_perulangan VALUES (1073, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1073);
INSERT INTO public.pola_perulangan VALUES (1074, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1074);
INSERT INTO public.pola_perulangan VALUES (1075, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1075);
INSERT INTO public.pola_perulangan VALUES (1076, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1076);
INSERT INTO public.pola_perulangan VALUES (1077, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1077);
INSERT INTO public.pola_perulangan VALUES (1078, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1078);
INSERT INTO public.pola_perulangan VALUES (1079, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1079);
INSERT INTO public.pola_perulangan VALUES (1080, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1080);
INSERT INTO public.pola_perulangan VALUES (1081, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:10', '2020-09-03 14:18:10', 1081);
INSERT INTO public.pola_perulangan VALUES (1082, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1082);
INSERT INTO public.pola_perulangan VALUES (1083, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1083);
INSERT INTO public.pola_perulangan VALUES (1084, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1084);
INSERT INTO public.pola_perulangan VALUES (1085, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1085);
INSERT INTO public.pola_perulangan VALUES (1086, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1086);
INSERT INTO public.pola_perulangan VALUES (1087, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1087);
INSERT INTO public.pola_perulangan VALUES (1088, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1088);
INSERT INTO public.pola_perulangan VALUES (1089, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1089);
INSERT INTO public.pola_perulangan VALUES (1090, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1090);
INSERT INTO public.pola_perulangan VALUES (1091, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1091);
INSERT INTO public.pola_perulangan VALUES (1092, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1092);
INSERT INTO public.pola_perulangan VALUES (1093, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1093);
INSERT INTO public.pola_perulangan VALUES (1094, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1094);
INSERT INTO public.pola_perulangan VALUES (1095, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1095);
INSERT INTO public.pola_perulangan VALUES (1096, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1096);
INSERT INTO public.pola_perulangan VALUES (1097, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1097);
INSERT INTO public.pola_perulangan VALUES (1098, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1098);
INSERT INTO public.pola_perulangan VALUES (1099, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1099);
INSERT INTO public.pola_perulangan VALUES (1100, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1100);
INSERT INTO public.pola_perulangan VALUES (1101, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1101);
INSERT INTO public.pola_perulangan VALUES (1102, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1102);
INSERT INTO public.pola_perulangan VALUES (1103, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1103);
INSERT INTO public.pola_perulangan VALUES (1104, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1104);
INSERT INTO public.pola_perulangan VALUES (1105, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1105);
INSERT INTO public.pola_perulangan VALUES (1106, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1106);
INSERT INTO public.pola_perulangan VALUES (1107, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1107);
INSERT INTO public.pola_perulangan VALUES (1108, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1108);
INSERT INTO public.pola_perulangan VALUES (1109, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1109);
INSERT INTO public.pola_perulangan VALUES (1110, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1110);
INSERT INTO public.pola_perulangan VALUES (1111, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1111);
INSERT INTO public.pola_perulangan VALUES (1112, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1112);
INSERT INTO public.pola_perulangan VALUES (1113, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1113);
INSERT INTO public.pola_perulangan VALUES (1114, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1114);
INSERT INTO public.pola_perulangan VALUES (1115, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1115);
INSERT INTO public.pola_perulangan VALUES (1116, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1116);
INSERT INTO public.pola_perulangan VALUES (1117, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1117);
INSERT INTO public.pola_perulangan VALUES (1118, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1118);
INSERT INTO public.pola_perulangan VALUES (1119, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1119);
INSERT INTO public.pola_perulangan VALUES (1120, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1120);
INSERT INTO public.pola_perulangan VALUES (1121, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1121);
INSERT INTO public.pola_perulangan VALUES (1122, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1122);
INSERT INTO public.pola_perulangan VALUES (1123, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1123);
INSERT INTO public.pola_perulangan VALUES (1124, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1124);
INSERT INTO public.pola_perulangan VALUES (1125, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1125);
INSERT INTO public.pola_perulangan VALUES (1126, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1126);
INSERT INTO public.pola_perulangan VALUES (1127, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1127);
INSERT INTO public.pola_perulangan VALUES (1128, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:11', '2020-09-03 14:18:11', 1128);
INSERT INTO public.pola_perulangan VALUES (1129, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1129);
INSERT INTO public.pola_perulangan VALUES (1130, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1130);
INSERT INTO public.pola_perulangan VALUES (1131, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1131);
INSERT INTO public.pola_perulangan VALUES (1132, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1132);
INSERT INTO public.pola_perulangan VALUES (1133, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1133);
INSERT INTO public.pola_perulangan VALUES (1134, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1134);
INSERT INTO public.pola_perulangan VALUES (1135, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1135);
INSERT INTO public.pola_perulangan VALUES (1136, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1136);
INSERT INTO public.pola_perulangan VALUES (1137, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1137);
INSERT INTO public.pola_perulangan VALUES (1138, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1138);
INSERT INTO public.pola_perulangan VALUES (1139, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1139);
INSERT INTO public.pola_perulangan VALUES (1140, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1140);
INSERT INTO public.pola_perulangan VALUES (1141, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1141);
INSERT INTO public.pola_perulangan VALUES (1142, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1142);
INSERT INTO public.pola_perulangan VALUES (1143, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1143);
INSERT INTO public.pola_perulangan VALUES (1144, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1144);
INSERT INTO public.pola_perulangan VALUES (1145, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1145);
INSERT INTO public.pola_perulangan VALUES (1146, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1146);
INSERT INTO public.pola_perulangan VALUES (1147, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1147);
INSERT INTO public.pola_perulangan VALUES (1148, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1148);
INSERT INTO public.pola_perulangan VALUES (1149, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1149);
INSERT INTO public.pola_perulangan VALUES (1150, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1150);
INSERT INTO public.pola_perulangan VALUES (1151, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1151);
INSERT INTO public.pola_perulangan VALUES (1152, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1152);
INSERT INTO public.pola_perulangan VALUES (1153, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1153);
INSERT INTO public.pola_perulangan VALUES (1154, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1154);
INSERT INTO public.pola_perulangan VALUES (1155, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1155);
INSERT INTO public.pola_perulangan VALUES (1156, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1156);
INSERT INTO public.pola_perulangan VALUES (1157, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1157);
INSERT INTO public.pola_perulangan VALUES (1158, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1158);
INSERT INTO public.pola_perulangan VALUES (1159, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1159);
INSERT INTO public.pola_perulangan VALUES (1160, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1160);
INSERT INTO public.pola_perulangan VALUES (1161, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1161);
INSERT INTO public.pola_perulangan VALUES (1162, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1162);
INSERT INTO public.pola_perulangan VALUES (1163, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1163);
INSERT INTO public.pola_perulangan VALUES (1164, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1164);
INSERT INTO public.pola_perulangan VALUES (1165, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1165);
INSERT INTO public.pola_perulangan VALUES (1166, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1166);
INSERT INTO public.pola_perulangan VALUES (1167, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1167);
INSERT INTO public.pola_perulangan VALUES (1168, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1168);
INSERT INTO public.pola_perulangan VALUES (1169, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1169);
INSERT INTO public.pola_perulangan VALUES (1170, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1170);
INSERT INTO public.pola_perulangan VALUES (1171, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1171);
INSERT INTO public.pola_perulangan VALUES (1172, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:12', '2020-09-03 14:18:12', 1172);
INSERT INTO public.pola_perulangan VALUES (1173, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1173);
INSERT INTO public.pola_perulangan VALUES (1174, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1174);
INSERT INTO public.pola_perulangan VALUES (1175, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1175);
INSERT INTO public.pola_perulangan VALUES (1176, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1176);
INSERT INTO public.pola_perulangan VALUES (1177, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1177);
INSERT INTO public.pola_perulangan VALUES (1178, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1178);
INSERT INTO public.pola_perulangan VALUES (1179, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1179);
INSERT INTO public.pola_perulangan VALUES (1180, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1180);
INSERT INTO public.pola_perulangan VALUES (1181, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1181);
INSERT INTO public.pola_perulangan VALUES (1182, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1182);
INSERT INTO public.pola_perulangan VALUES (1183, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1183);
INSERT INTO public.pola_perulangan VALUES (1184, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1184);
INSERT INTO public.pola_perulangan VALUES (1185, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1185);
INSERT INTO public.pola_perulangan VALUES (1186, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1186);
INSERT INTO public.pola_perulangan VALUES (1187, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1187);
INSERT INTO public.pola_perulangan VALUES (1188, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1188);
INSERT INTO public.pola_perulangan VALUES (1189, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1189);
INSERT INTO public.pola_perulangan VALUES (1190, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1190);
INSERT INTO public.pola_perulangan VALUES (1191, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1191);
INSERT INTO public.pola_perulangan VALUES (1192, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1192);
INSERT INTO public.pola_perulangan VALUES (1193, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1193);
INSERT INTO public.pola_perulangan VALUES (1194, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1194);
INSERT INTO public.pola_perulangan VALUES (1195, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1195);
INSERT INTO public.pola_perulangan VALUES (1196, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1196);
INSERT INTO public.pola_perulangan VALUES (1197, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1197);
INSERT INTO public.pola_perulangan VALUES (1198, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1198);
INSERT INTO public.pola_perulangan VALUES (1199, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1199);
INSERT INTO public.pola_perulangan VALUES (1200, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1200);
INSERT INTO public.pola_perulangan VALUES (1201, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1201);
INSERT INTO public.pola_perulangan VALUES (1202, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1202);
INSERT INTO public.pola_perulangan VALUES (1203, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1203);
INSERT INTO public.pola_perulangan VALUES (1204, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1204);
INSERT INTO public.pola_perulangan VALUES (1205, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1205);
INSERT INTO public.pola_perulangan VALUES (1206, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1206);
INSERT INTO public.pola_perulangan VALUES (1207, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1207);
INSERT INTO public.pola_perulangan VALUES (1208, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1208);
INSERT INTO public.pola_perulangan VALUES (1209, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1209);
INSERT INTO public.pola_perulangan VALUES (1210, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1210);
INSERT INTO public.pola_perulangan VALUES (1211, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1211);
INSERT INTO public.pola_perulangan VALUES (1212, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1212);
INSERT INTO public.pola_perulangan VALUES (1213, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1213);
INSERT INTO public.pola_perulangan VALUES (1214, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1214);
INSERT INTO public.pola_perulangan VALUES (1215, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1215);
INSERT INTO public.pola_perulangan VALUES (1216, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1216);
INSERT INTO public.pola_perulangan VALUES (1217, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1217);
INSERT INTO public.pola_perulangan VALUES (1218, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:13', '2020-09-03 14:18:13', 1218);
INSERT INTO public.pola_perulangan VALUES (1219, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1219);
INSERT INTO public.pola_perulangan VALUES (1220, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1220);
INSERT INTO public.pola_perulangan VALUES (1221, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1221);
INSERT INTO public.pola_perulangan VALUES (1222, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1222);
INSERT INTO public.pola_perulangan VALUES (1223, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1223);
INSERT INTO public.pola_perulangan VALUES (1224, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1224);
INSERT INTO public.pola_perulangan VALUES (1225, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1225);
INSERT INTO public.pola_perulangan VALUES (1226, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1226);
INSERT INTO public.pola_perulangan VALUES (1227, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1227);
INSERT INTO public.pola_perulangan VALUES (1228, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1228);
INSERT INTO public.pola_perulangan VALUES (1229, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1229);
INSERT INTO public.pola_perulangan VALUES (1230, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1230);
INSERT INTO public.pola_perulangan VALUES (1231, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1231);
INSERT INTO public.pola_perulangan VALUES (1232, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1232);
INSERT INTO public.pola_perulangan VALUES (1233, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1233);
INSERT INTO public.pola_perulangan VALUES (1234, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1234);
INSERT INTO public.pola_perulangan VALUES (1235, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1235);
INSERT INTO public.pola_perulangan VALUES (1236, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1236);
INSERT INTO public.pola_perulangan VALUES (1237, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1237);
INSERT INTO public.pola_perulangan VALUES (1238, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1238);
INSERT INTO public.pola_perulangan VALUES (1239, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1239);
INSERT INTO public.pola_perulangan VALUES (1240, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1240);
INSERT INTO public.pola_perulangan VALUES (1241, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1241);
INSERT INTO public.pola_perulangan VALUES (1242, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1242);
INSERT INTO public.pola_perulangan VALUES (1243, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1243);
INSERT INTO public.pola_perulangan VALUES (1244, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1244);
INSERT INTO public.pola_perulangan VALUES (1245, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1245);
INSERT INTO public.pola_perulangan VALUES (1246, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1246);
INSERT INTO public.pola_perulangan VALUES (1247, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1247);
INSERT INTO public.pola_perulangan VALUES (1248, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1248);
INSERT INTO public.pola_perulangan VALUES (1249, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1249);
INSERT INTO public.pola_perulangan VALUES (1250, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1250);
INSERT INTO public.pola_perulangan VALUES (1251, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1251);
INSERT INTO public.pola_perulangan VALUES (1252, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1252);
INSERT INTO public.pola_perulangan VALUES (1253, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1253);
INSERT INTO public.pola_perulangan VALUES (1254, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1254);
INSERT INTO public.pola_perulangan VALUES (1255, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1255);
INSERT INTO public.pola_perulangan VALUES (1256, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1256);
INSERT INTO public.pola_perulangan VALUES (1257, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1257);
INSERT INTO public.pola_perulangan VALUES (1258, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1258);
INSERT INTO public.pola_perulangan VALUES (1259, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1259);
INSERT INTO public.pola_perulangan VALUES (1260, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1260);
INSERT INTO public.pola_perulangan VALUES (1261, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1261);
INSERT INTO public.pola_perulangan VALUES (1262, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1262);
INSERT INTO public.pola_perulangan VALUES (1263, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1263);
INSERT INTO public.pola_perulangan VALUES (1264, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:14', '2020-09-03 14:18:14', 1264);
INSERT INTO public.pola_perulangan VALUES (1265, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1265);
INSERT INTO public.pola_perulangan VALUES (1266, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1266);
INSERT INTO public.pola_perulangan VALUES (1267, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1267);
INSERT INTO public.pola_perulangan VALUES (1268, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1268);
INSERT INTO public.pola_perulangan VALUES (1269, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1269);
INSERT INTO public.pola_perulangan VALUES (1270, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1270);
INSERT INTO public.pola_perulangan VALUES (1271, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1271);
INSERT INTO public.pola_perulangan VALUES (1272, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1272);
INSERT INTO public.pola_perulangan VALUES (1273, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1273);
INSERT INTO public.pola_perulangan VALUES (1274, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1274);
INSERT INTO public.pola_perulangan VALUES (1275, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1275);
INSERT INTO public.pola_perulangan VALUES (1276, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1276);
INSERT INTO public.pola_perulangan VALUES (1277, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1277);
INSERT INTO public.pola_perulangan VALUES (1278, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1278);
INSERT INTO public.pola_perulangan VALUES (1279, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1279);
INSERT INTO public.pola_perulangan VALUES (1280, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1280);
INSERT INTO public.pola_perulangan VALUES (1281, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1281);
INSERT INTO public.pola_perulangan VALUES (1282, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1282);
INSERT INTO public.pola_perulangan VALUES (1283, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1283);
INSERT INTO public.pola_perulangan VALUES (1284, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1284);
INSERT INTO public.pola_perulangan VALUES (1285, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1285);
INSERT INTO public.pola_perulangan VALUES (1286, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1286);
INSERT INTO public.pola_perulangan VALUES (1287, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1287);
INSERT INTO public.pola_perulangan VALUES (1288, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1288);
INSERT INTO public.pola_perulangan VALUES (1289, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1289);
INSERT INTO public.pola_perulangan VALUES (1290, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1290);
INSERT INTO public.pola_perulangan VALUES (1291, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1291);
INSERT INTO public.pola_perulangan VALUES (1292, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1292);
INSERT INTO public.pola_perulangan VALUES (1293, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1293);
INSERT INTO public.pola_perulangan VALUES (1294, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1294);
INSERT INTO public.pola_perulangan VALUES (1295, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1295);
INSERT INTO public.pola_perulangan VALUES (1296, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1296);
INSERT INTO public.pola_perulangan VALUES (1297, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1297);
INSERT INTO public.pola_perulangan VALUES (1298, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1298);
INSERT INTO public.pola_perulangan VALUES (1299, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1299);
INSERT INTO public.pola_perulangan VALUES (1300, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1300);
INSERT INTO public.pola_perulangan VALUES (1301, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1301);
INSERT INTO public.pola_perulangan VALUES (1302, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1302);
INSERT INTO public.pola_perulangan VALUES (1303, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1303);
INSERT INTO public.pola_perulangan VALUES (1304, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1304);
INSERT INTO public.pola_perulangan VALUES (1305, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1305);
INSERT INTO public.pola_perulangan VALUES (1306, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1306);
INSERT INTO public.pola_perulangan VALUES (1307, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1307);
INSERT INTO public.pola_perulangan VALUES (1308, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:15', '2020-09-03 14:18:15', 1308);
INSERT INTO public.pola_perulangan VALUES (1309, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1309);
INSERT INTO public.pola_perulangan VALUES (1310, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1310);
INSERT INTO public.pola_perulangan VALUES (1311, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1311);
INSERT INTO public.pola_perulangan VALUES (1312, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1312);
INSERT INTO public.pola_perulangan VALUES (1313, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1313);
INSERT INTO public.pola_perulangan VALUES (1314, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1314);
INSERT INTO public.pola_perulangan VALUES (1315, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1315);
INSERT INTO public.pola_perulangan VALUES (1316, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1316);
INSERT INTO public.pola_perulangan VALUES (1317, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1317);
INSERT INTO public.pola_perulangan VALUES (1318, 1, 1, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1318);
INSERT INTO public.pola_perulangan VALUES (1319, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1319);
INSERT INTO public.pola_perulangan VALUES (1320, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1320);
INSERT INTO public.pola_perulangan VALUES (1321, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1321);
INSERT INTO public.pola_perulangan VALUES (1322, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1322);
INSERT INTO public.pola_perulangan VALUES (1323, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1323);
INSERT INTO public.pola_perulangan VALUES (1324, 1, 2, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1324);
INSERT INTO public.pola_perulangan VALUES (1325, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1325);
INSERT INTO public.pola_perulangan VALUES (1326, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1326);
INSERT INTO public.pola_perulangan VALUES (1327, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1327);
INSERT INTO public.pola_perulangan VALUES (1328, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1328);
INSERT INTO public.pola_perulangan VALUES (1329, 1, 3, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1329);
INSERT INTO public.pola_perulangan VALUES (1330, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1330);
INSERT INTO public.pola_perulangan VALUES (1331, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1331);
INSERT INTO public.pola_perulangan VALUES (1332, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1332);
INSERT INTO public.pola_perulangan VALUES (1333, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1333);
INSERT INTO public.pola_perulangan VALUES (1334, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1334);
INSERT INTO public.pola_perulangan VALUES (1335, 1, 4, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1335);
INSERT INTO public.pola_perulangan VALUES (1336, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1336);
INSERT INTO public.pola_perulangan VALUES (1337, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1337);
INSERT INTO public.pola_perulangan VALUES (1338, 1, 5, NULL, NULL, NULL, '2020-09-03 14:18:16', '2020-09-03 14:18:16', 1338);


--
-- Data for Name: program_studi; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.program_studi VALUES (2, 'TEKNIK KELAUTAN', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.program_studi VALUES (3, 'TEKNIK LINGKUNGAN', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.program_studi VALUES (4, 'TEKNIK PERTAMBANGAN', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.program_studi VALUES (5, 'PERENCANAAN WILAYAH DAN KOTA', '2020-09-03 14:17:51', '2020-09-03 14:17:51');
INSERT INTO public.program_studi VALUES (6, 'TEKNIK SIPIL', '2020-09-03 14:17:52', '2020-09-03 14:17:52');
INSERT INTO public.program_studi VALUES (10, 'TEKNIK ELEKTRO', '2020-09-03 14:18:09', '2020-09-03 14:18:09');
INSERT INTO public.program_studi VALUES (11, 'TEKNIK INDUSTRI', '2020-09-03 14:18:10', '2020-09-03 14:18:10');
INSERT INTO public.program_studi VALUES (12, 'INFORMATIKA', '2020-09-03 14:18:11', '2020-09-03 14:18:11');
INSERT INTO public.program_studi VALUES (13, 'TEKNIK KIMIA', '2020-09-03 14:18:12', '2020-09-03 14:18:12');
INSERT INTO public.program_studi VALUES (14, 'TEKNIK MESIN', '2020-09-03 14:18:14', '2020-09-03 14:18:14');


--
-- Data for Name: ruangan; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.ruangan VALUES (1, 'LABHIDROLIKA', 'LABHIDROLIKA', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (2, 'D31', 'D31', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (3, 'D32', 'D32', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (4, 'LABMEKTAN', 'LABMEKTAN', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (5, 'D04', 'D04', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (6, 'D25', 'D25', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (7, 'D23', 'D23', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (8, 'D21', 'D21', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (9, 'D22', 'D22', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (10, 'RS2/RSSIPIL', 'RS2/RSSIPIL', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (11, 'D05', 'D05', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (12, 'D35', 'D35', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (13, 'S2SIPIL', 'S2SIPIL', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (14, 'D36', 'D36', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (15, 'D18', 'D18', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (16, 'D34', 'D34', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.ruangan VALUES (17, 'D37', 'D37', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (18, 'D28', 'D28', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (19, 'D26', 'D26', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (20, 'D27', 'D27', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (21, 'LAB', 'LAB', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (22, 'D01/D02', 'D01/D02', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (23, 'D06', 'D06', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (24, 'D20', 'D20', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (25, 'D30', 'D30', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (26, 'D03', 'D03', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (27, 'D24', 'D24', '2020-09-03 14:17:50', '2020-09-03 14:17:50');
INSERT INTO public.ruangan VALUES (28, 'D33', 'D33', '2020-09-03 14:17:51', '2020-09-03 14:17:51');
INSERT INTO public.ruangan VALUES (29, 'D07', 'D07', '2020-09-03 14:17:51', '2020-09-03 14:17:51');
INSERT INTO public.ruangan VALUES (30, '', '', '2020-09-03 14:17:52', '2020-09-03 14:17:52');
INSERT INTO public.ruangan VALUES (31, 'LABBETON', 'LABBETON', '2020-09-03 14:17:52', '2020-09-03 14:17:52');
INSERT INTO public.ruangan VALUES (32, 'D29', 'D29', '2020-09-03 14:17:52', '2020-09-03 14:17:52');
INSERT INTO public.ruangan VALUES (33, 'GKBA', 'GKBA', '2020-09-03 14:17:54', '2020-09-03 14:17:54');
INSERT INTO public.ruangan VALUES (34, 'RS2(RSSIPIL)', 'RS2(RSSIPIL)', '2020-09-03 14:17:54', '2020-09-03 14:17:54');
INSERT INTO public.ruangan VALUES (35, 'D39', 'D39', '2020-09-03 14:17:54', '2020-09-03 14:17:54');
INSERT INTO public.ruangan VALUES (36, 'D38', 'D38', '2020-09-03 14:17:54', '2020-09-03 14:17:54');
INSERT INTO public.ruangan VALUES (37, 'WS', 'WS', '2020-09-03 14:17:54', '2020-09-03 14:17:54');
INSERT INTO public.ruangan VALUES (38, 'D02', 'D02', '2020-09-03 14:17:54', '2020-09-03 14:17:54');
INSERT INTO public.ruangan VALUES (39, 'D03K(S2EKSTRA)', 'D03K(S2EKSTRA)', '2020-09-03 14:17:56', '2020-09-03 14:17:56');
INSERT INTO public.ruangan VALUES (40, 'LABMANAJEMEN', 'LABMANAJEMEN', '2020-09-03 14:17:58', '2020-09-03 14:17:58');
INSERT INTO public.ruangan VALUES (41, 'LABMEKANIKATANAH', 'LABMEKANIKATANAH', '2020-09-03 14:17:59', '2020-09-03 14:17:59');
INSERT INTO public.ruangan VALUES (42, 'GKBUNTAN', 'GKBUNTAN', '2020-09-03 14:18:04', '2020-09-03 14:18:04');
INSERT INTO public.ruangan VALUES (43, 'D45', 'D45', '2020-09-03 14:18:04', '2020-09-03 14:18:04');
INSERT INTO public.ruangan VALUES (44, 'D41', 'D41', '2020-09-03 14:18:05', '2020-09-03 14:18:05');
INSERT INTO public.ruangan VALUES (45, 'D42', 'D42', '2020-09-03 14:18:05', '2020-09-03 14:18:05');
INSERT INTO public.ruangan VALUES (46, 'D46', 'D46', '2020-09-03 14:18:05', '2020-09-03 14:18:05');
INSERT INTO public.ruangan VALUES (47, 'D40', 'D40', '2020-09-03 14:18:05', '2020-09-03 14:18:05');
INSERT INTO public.ruangan VALUES (48, 'D43', 'D43', '2020-09-03 14:18:05', '2020-09-03 14:18:05');
INSERT INTO public.ruangan VALUES (49, 'D44', 'D44', '2020-09-03 14:18:05', '2020-09-03 14:18:05');
INSERT INTO public.ruangan VALUES (50, 'LABPUSKOM', 'LABPUSKOM', '2020-09-03 14:18:07', '2020-09-03 14:18:07');
INSERT INTO public.ruangan VALUES (51, 'D01', 'D01', '2020-09-03 14:18:09', '2020-09-03 14:18:09');
INSERT INTO public.ruangan VALUES (52, 'LABTTT', 'LABTTT', '2020-09-03 14:18:09', '2020-09-03 14:18:09');
INSERT INTO public.ruangan VALUES (53, 'LABKENDALI', 'LABKENDALI', '2020-09-03 14:18:09', '2020-09-03 14:18:09');
INSERT INTO public.ruangan VALUES (54, 'LABDIGITAL', 'LABDIGITAL', '2020-09-03 14:18:09', '2020-09-03 14:18:09');
INSERT INTO public.ruangan VALUES (55, 'LABDISTRIBUSI1', 'LABDISTRIBUSI1', '2020-09-03 14:18:09', '2020-09-03 14:18:09');
INSERT INTO public.ruangan VALUES (56, 'LABOSI', 'LABOSI', '2020-09-03 14:18:10', '2020-09-03 14:18:10');
INSERT INTO public.ruangan VALUES (57, 'GKB', 'GKB', '2020-09-03 14:18:10', '2020-09-03 14:18:10');
INSERT INTO public.ruangan VALUES (58, 'RD', 'RD', '2020-09-03 14:18:11', '2020-09-03 14:18:11');
INSERT INTO public.ruangan VALUES (59, 'RB', 'RB', '2020-09-03 14:18:11', '2020-09-03 14:18:11');
INSERT INTO public.ruangan VALUES (60, 'D02/MAGISTER', 'D02/MAGISTER', '2020-09-03 14:18:15', '2020-09-03 14:18:15');
INSERT INTO public.ruangan VALUES (61, 'LABTELKOM', 'LABTELKOM', '2020-09-03 14:18:16', '2020-09-03 14:18:16');


--
-- Data for Name: tahun_ajaran; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.tahun_ajaran VALUES (1, 2018, 2019, '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.tahun_ajaran VALUES (2, 2019, 2020, '2020-09-03 14:17:53', '2020-09-03 14:17:53');


--
-- Data for Name: tipe_semester; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.tipe_semester VALUES (1, 'GASAL', '2020-09-03 14:17:49', '2020-09-03 14:17:49');
INSERT INTO public.tipe_semester VALUES (2, 'GENAP', '2020-09-03 14:17:59', '2020-09-03 14:17:59');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: atomicbomber
--

INSERT INTO public.users VALUES (1, 'Administrator', 'admin', NULL, NULL, '$2y$10$U0laPXWsBuqG6j9hZPkfE.X/QUnML0wXaShDct8.3Ib54wI0DuYaO', NULL, '2020-09-03 14:17:49', '2020-09-03 14:17:49');


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: kegiatan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.kegiatan_id_seq', 1338, true);


--
-- Name: kelas_mata_kuliah_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.kelas_mata_kuliah_id_seq', 1404, true);


--
-- Name: mata_kuliah_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.mata_kuliah_id_seq', 546, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.migrations_id_seq', 22, true);


--
-- Name: pola_perulangan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.pola_perulangan_id_seq', 1338, true);


--
-- Name: program_studi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.program_studi_id_seq', 14, true);


--
-- Name: ruangan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.ruangan_id_seq', 61, true);


--
-- Name: tahun_ajaran_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.tahun_ajaran_id_seq', 2, true);


--
-- Name: tipe_semester_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.tipe_semester_id_seq', 2, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atomicbomber
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: kegiatan kegiatan_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kegiatan
    ADD CONSTRAINT kegiatan_pkey PRIMARY KEY (id);


--
-- Name: kelas_mata_kuliah kelas_mata_kuliah_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kelas_mata_kuliah
    ADD CONSTRAINT kelas_mata_kuliah_pkey PRIMARY KEY (id);


--
-- Name: mata_kuliah mata_kuliah_kode_unique; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.mata_kuliah
    ADD CONSTRAINT mata_kuliah_kode_unique UNIQUE (kode);


--
-- Name: mata_kuliah mata_kuliah_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.mata_kuliah
    ADD CONSTRAINT mata_kuliah_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: pola_perulangan pola_perulangan_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.pola_perulangan
    ADD CONSTRAINT pola_perulangan_pkey PRIMARY KEY (id);


--
-- Name: program_studi program_studi_nama_unique; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.program_studi
    ADD CONSTRAINT program_studi_nama_unique UNIQUE (nama);


--
-- Name: program_studi program_studi_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.program_studi
    ADD CONSTRAINT program_studi_pkey PRIMARY KEY (id);


--
-- Name: ruangan ruangan_nama_unique; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.ruangan
    ADD CONSTRAINT ruangan_nama_unique UNIQUE (nama);


--
-- Name: ruangan ruangan_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.ruangan
    ADD CONSTRAINT ruangan_pkey PRIMARY KEY (id);


--
-- Name: tahun_ajaran tahun_ajaran_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.tahun_ajaran
    ADD CONSTRAINT tahun_ajaran_pkey PRIMARY KEY (id);


--
-- Name: tahun_ajaran tahun_ajaran_tahun_mulai_tahun_selesai_unique; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.tahun_ajaran
    ADD CONSTRAINT tahun_ajaran_tahun_mulai_tahun_selesai_unique UNIQUE (tahun_mulai, tahun_selesai);


--
-- Name: tipe_semester tipe_semester_nama_unique; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.tipe_semester
    ADD CONSTRAINT tipe_semester_nama_unique UNIQUE (nama);


--
-- Name: tipe_semester tipe_semester_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.tipe_semester
    ADD CONSTRAINT tipe_semester_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_unique; Type: CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_unique UNIQUE (username);


--
-- Name: kegiatan_kegiatan_sumber_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX kegiatan_kegiatan_sumber_id_index ON public.kegiatan USING btree (kegiatan_sumber_id);


--
-- Name: kegiatan_mata_kuliah_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX kegiatan_mata_kuliah_id_index ON public.kegiatan USING btree (mata_kuliah_id);


--
-- Name: kegiatan_ruangan_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX kegiatan_ruangan_id_index ON public.kegiatan USING btree (ruangan_id);


--
-- Name: kelas_mata_kuliah_kegiatan_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX kelas_mata_kuliah_kegiatan_id_index ON public.kelas_mata_kuliah USING btree (kegiatan_id);


--
-- Name: kelas_mata_kuliah_mata_kuliah_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX kelas_mata_kuliah_mata_kuliah_id_index ON public.kelas_mata_kuliah USING btree (mata_kuliah_id);


--
-- Name: kelas_mata_kuliah_program_studi_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX kelas_mata_kuliah_program_studi_id_index ON public.kelas_mata_kuliah USING btree (program_studi_id);


--
-- Name: kelas_mata_kuliah_tahun_ajaran_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX kelas_mata_kuliah_tahun_ajaran_id_index ON public.kelas_mata_kuliah USING btree (tahun_ajaran_id);


--
-- Name: kelas_mata_kuliah_tipe_semester_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX kelas_mata_kuliah_tipe_semester_id_index ON public.kelas_mata_kuliah USING btree (tipe_semester_id);


--
-- Name: mata_kuliah_program_studi_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX mata_kuliah_program_studi_id_index ON public.mata_kuliah USING btree (program_studi_id);


--
-- Name: password_resets_email_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX password_resets_email_index ON public.password_resets USING btree (email);


--
-- Name: pola_perulangan_kegiatan_id_index; Type: INDEX; Schema: public; Owner: atomicbomber
--

CREATE INDEX pola_perulangan_kegiatan_id_index ON public.pola_perulangan USING btree (kegiatan_id);


--
-- Name: kegiatan kegiatan_kegiatan_sumber_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kegiatan
    ADD CONSTRAINT kegiatan_kegiatan_sumber_id_foreign FOREIGN KEY (kegiatan_sumber_id) REFERENCES public.kegiatan(id);


--
-- Name: kegiatan kegiatan_mata_kuliah_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kegiatan
    ADD CONSTRAINT kegiatan_mata_kuliah_id_foreign FOREIGN KEY (mata_kuliah_id) REFERENCES public.mata_kuliah(id);


--
-- Name: kegiatan kegiatan_ruangan_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kegiatan
    ADD CONSTRAINT kegiatan_ruangan_id_foreign FOREIGN KEY (ruangan_id) REFERENCES public.ruangan(id);


--
-- Name: kelas_mata_kuliah kelas_mata_kuliah_kegiatan_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kelas_mata_kuliah
    ADD CONSTRAINT kelas_mata_kuliah_kegiatan_id_foreign FOREIGN KEY (kegiatan_id) REFERENCES public.kegiatan(id) ON DELETE SET NULL;


--
-- Name: kelas_mata_kuliah kelas_mata_kuliah_mata_kuliah_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kelas_mata_kuliah
    ADD CONSTRAINT kelas_mata_kuliah_mata_kuliah_id_foreign FOREIGN KEY (mata_kuliah_id) REFERENCES public.mata_kuliah(id);


--
-- Name: kelas_mata_kuliah kelas_mata_kuliah_program_studi_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kelas_mata_kuliah
    ADD CONSTRAINT kelas_mata_kuliah_program_studi_id_foreign FOREIGN KEY (program_studi_id) REFERENCES public.program_studi(id);


--
-- Name: kelas_mata_kuliah kelas_mata_kuliah_tahun_ajaran_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kelas_mata_kuliah
    ADD CONSTRAINT kelas_mata_kuliah_tahun_ajaran_id_foreign FOREIGN KEY (tahun_ajaran_id) REFERENCES public.tahun_ajaran(id);


--
-- Name: kelas_mata_kuliah kelas_mata_kuliah_tipe_semester_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.kelas_mata_kuliah
    ADD CONSTRAINT kelas_mata_kuliah_tipe_semester_id_foreign FOREIGN KEY (tipe_semester_id) REFERENCES public.tipe_semester(id);


--
-- Name: mata_kuliah mata_kuliah_program_studi_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.mata_kuliah
    ADD CONSTRAINT mata_kuliah_program_studi_id_foreign FOREIGN KEY (program_studi_id) REFERENCES public.program_studi(id) ON DELETE CASCADE;


--
-- Name: pola_perulangan pola_perulangan_kegiatan_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: atomicbomber
--

ALTER TABLE ONLY public.pola_perulangan
    ADD CONSTRAINT pola_perulangan_kegiatan_id_foreign FOREIGN KEY (kegiatan_id) REFERENCES public.kegiatan(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


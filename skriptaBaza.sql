--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

-- Started on 2024-08-26 07:21:35

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
-- TOC entry 4928 (class 1262 OID 24875)
-- Name: BAZA_TBP; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "BAZA_TBP" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Croatian_Croatia.1250';


ALTER DATABASE "BAZA_TBP" OWNER TO postgres;

\connect "BAZA_TBP"

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
-- TOC entry 862 (class 1247 OID 24877)
-- Name: dogadaj_tip; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.dogadaj_tip AS ENUM (
    'Zalijevanje',
    'Prihranjivanje',
    'Presađivanje'
);


ALTER TYPE public.dogadaj_tip OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 24958)
-- Name: min_max(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.min_max() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.max_temp < NEW.min_temp THEN
        RAISE EXCEPTION '%','Maksimalna temperatura ne može biti manja od minimalne.';
    END IF;
    
    IF NEW.max_vlaga < NEW.min_vlaga THEN
        RAISE EXCEPTION '%','Maksimalna vlažnost ne može biti manja od minimalne.';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.min_max() OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 24964)
-- Name: provjeri_azuriranje_biljke(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.provjeri_azuriranje_biljke() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.ime = OLD.ime
        AND NEW.zalijevanje = OLD.zalijevanje
        AND NEW.prihranjivanje = OLD.prihranjivanje
        AND NEW.presadivanje = OLD.presadivanje
        AND NEW.min_temp = OLD.min_temp
        AND NEW.max_temp = OLD.max_temp
        AND NEW.min_vlaga = OLD.min_vlaga
        AND NEW.max_vlaga = OLD.max_vlaga
        AND NEW.datum_sadnje = OLD.datum_sadnje
    THEN
        RAISE EXCEPTION '%','Ništa nije ažurirano.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.provjeri_azuriranje_biljke() OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 24962)
-- Name: provjeri_biljku(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.provjeri_biljku() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF LENGTH(NEW.ime)=0 THEN
        RAISE EXCEPTION '%','Ime biljke ne može biti prazno.';
    END IF;
    IF NEW.zalijevanje < 1 OR NEW.zalijevanje > 30 THEN
        RAISE EXCEPTION  '%','Vrijednost zalijevanja mora biti između 1 i 30 dana.';
    END IF;
    IF NEW.prihranjivanje < 15 OR NEW.prihranjivanje > 365 THEN
        RAISE EXCEPTION '%','Vrijednost prihranjivanja mora biti između 15 i 365 dana.';
    END IF;
    IF NEW.presadivanje < 180 OR NEW.presadivanje > 730 THEN
        RAISE EXCEPTION '%','Vrijednost presađivanja mora biti između 180 i 730 dana.';
    END IF;
    IF NEW.min_temp < -10 OR NEW.max_temp > 50 THEN
        RAISE EXCEPTION '%','Temperatura mora biti između -10 i 50 stupnjeva Celzijusa.';
    END IF;
    IF NEW.min_vlaga < 0 OR NEW.max_vlaga > 100 THEN
        RAISE EXCEPTION '%','Vlažnost mora biti između 0% i 100%.';
    END IF;
	IF NEW.datum_sadnje > CURRENT_DATE THEN
        RAISE EXCEPTION '%','Datum sadnje ne može biti u budućnosti.';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.provjeri_biljku() OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 24972)
-- Name: provjeri_datum_dogadaja(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.provjeri_datum_dogadaja() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    --je li datum u budućnosti
    IF NEW.datum > CURRENT_DATE THEN
        RAISE EXCEPTION 'Datum događaja ne može biti u budućnosti.';
    END IF;

    --je li datum stariji od tjedan dana
    IF NEW.datum < CURRENT_DATE - INTERVAL '7 days' THEN
        RAISE EXCEPTION 'Datum događaja ne smije biti stariji od tjedan dana.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.provjeri_datum_dogadaja() OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 24974)
-- Name: provjeri_datum_podsjetnika(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.provjeri_datum_podsjetnika() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    --je li datum u prošlosti
    IF NEW.datum < CURRENT_DATE THEN
        -- postavljanje datuma na trenutni datum ako je u prošlosti
        NEW.datum = CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.provjeri_datum_podsjetnika() OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 24966)
-- Name: provjeri_dnevni_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.provjeri_dnevni_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.temperaturaDanas < -10 OR NEW.temperaturaDanas > 50 THEN
        RAISE EXCEPTION '%','Temperatura mora biti između -10 i 50 stupnjeva Celzijusa.';
    END IF;
    IF NEW.vlagaDanas < 0 OR NEW.vlagaDanas > 100 THEN
        RAISE EXCEPTION '%','Vlažnost mora biti između 0% i 100%.';
    END IF;
    
    IF EXISTS (SELECT 1 FROM dnevni_log WHERE biljka_id = NEW.biljka_id AND DATE(datum) = DATE(NEW.datum)) THEN
        RAISE EXCEPTION '%','Već postoji dnevni log za ovu biljku na današnji datum.';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.provjeri_dnevni_log() OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 24970)
-- Name: provjeri_dodavanje_dogadaja(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.provjeri_dodavanje_dogadaja() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.biljka_id IS NULL OR NEW.datum IS NULL OR NEW.tip IS NULL THEN
        RAISE EXCEPTION '%','Odaberite biljku, događaj i datum.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.provjeri_dodavanje_dogadaja() OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 24960)
-- Name: provjeri_sliku(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.provjeri_sliku() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF LENGTH(NEW.opis) > 100 THEN
        RAISE EXCEPTION '%','Dozvoljeno 100 znakova.';
    END IF;
	IF LENGTH(NEW.opis) = 0 THEN
		NEW.opis = 'Nema opisa.';
	END IF;
	IF LENGTH(NEW.slikica) > 5 * 1024 * 1024 THEN
        RAISE EXCEPTION 'Slika ne smije biti veća od 5 MB.';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.provjeri_sliku() OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 24968)
-- Name: stvori_podsjetnik(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stvori_podsjetnik() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    broj_dana INT;
BEGIN
    IF NEW.tip = 'Zalijevanje' THEN
        SELECT zalijevanje INTO broj_dana FROM biljka WHERE biljka_id = NEW.biljka_id;
    ELSIF NEW.tip = 'Prihranjivanje' THEN
        SELECT prihranjivanje INTO broj_dana FROM biljka WHERE biljka_id = NEW.biljka_id;
    ELSIF NEW.tip = 'Presađivanje' THEN
        SELECT presadivanje INTO broj_dana FROM biljka WHERE biljka_id = NEW.biljka_id;
    ELSE
        RAISE EXCEPTION 'Nepoznati tip događaja: %', NEW.tip;
    END IF;

    --ako postoji podsjetnik -> update
    IF EXISTS (SELECT 1 FROM podsjetnik WHERE biljka_id = NEW.biljka_id AND aktivnost = NEW.tip) THEN
        UPDATE podsjetnik SET datum = NEW.datum + broj_dana WHERE biljka_id = NEW.biljka_id AND aktivnost = NEW.tip;
    ELSE
        --ako ne postoji -> stvori novi podsjetnik
        INSERT INTO podsjetnik (biljka_id, datum, aktivnost) VALUES (NEW.biljka_id, NEW.datum + broj_dana, NEW.tip);
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.stvori_podsjetnik() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 24956)
-- Name: zapisivanje_povijesti_biljke(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.zapisivanje_povijesti_biljke() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        INSERT INTO biljka_povijest (biljka_id, ime, vrsta, datum_sadnje, zalijevanje, prihranjivanje, presadivanje, min_temp, max_temp, min_vlaga, max_vlaga, dodatno, operacija)
        VALUES (NEW.biljka_id, NEW.ime, NEW.vrsta, NEW.datum_sadnje, NEW.zalijevanje, NEW.prihranjivanje, NEW.presadivanje, NEW.min_temp, NEW.max_temp, NEW.min_vlaga, NEW.max_vlaga, NEW.dodatno, TG_OP);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.zapisivanje_povijesti_biljke() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 24884)
-- Name: biljka; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.biljka (
    biljka_id integer NOT NULL,
    ime character varying(50) NOT NULL,
    vrsta character varying(50),
    datum_sadnje date DEFAULT CURRENT_DATE,
    zalijevanje integer NOT NULL,
    prihranjivanje integer NOT NULL,
    presadivanje integer NOT NULL,
    min_temp double precision NOT NULL,
    max_temp double precision NOT NULL,
    min_vlaga integer NOT NULL,
    max_vlaga integer NOT NULL,
    dodatno text
);


ALTER TABLE public.biljka OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 24883)
-- Name: biljka_biljka_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.biljka_biljka_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.biljka_biljka_id_seq OWNER TO postgres;

--
-- TOC entry 4929 (class 0 OID 0)
-- Dependencies: 215
-- Name: biljka_biljka_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.biljka_biljka_id_seq OWNED BY public.biljka.biljka_id;


--
-- TOC entry 218 (class 1259 OID 24894)
-- Name: biljka_povijest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.biljka_povijest (
    povijest_id integer NOT NULL,
    biljka_id integer NOT NULL,
    ime character varying(50) NOT NULL,
    vrsta character varying(50),
    datum_sadnje date NOT NULL,
    zalijevanje integer NOT NULL,
    prihranjivanje integer NOT NULL,
    presadivanje integer NOT NULL,
    min_temp double precision NOT NULL,
    max_temp double precision NOT NULL,
    min_vlaga integer NOT NULL,
    max_vlaga integer NOT NULL,
    dodatno text,
    operacija character varying(10) NOT NULL,
    vrijeme_zapisa timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.biljka_povijest OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 24893)
-- Name: biljka_povijest_povijest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.biljka_povijest_povijest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.biljka_povijest_povijest_id_seq OWNER TO postgres;

--
-- TOC entry 4930 (class 0 OID 0)
-- Dependencies: 217
-- Name: biljka_povijest_povijest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.biljka_povijest_povijest_id_seq OWNED BY public.biljka_povijest.povijest_id;


--
-- TOC entry 224 (class 1259 OID 24932)
-- Name: dnevni_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dnevni_log (
    log_id integer NOT NULL,
    biljka_id integer,
    temperaturadanas double precision NOT NULL,
    vlagadanas integer NOT NULL,
    datum timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.dnevni_log OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 24931)
-- Name: dnevni_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dnevni_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dnevni_log_log_id_seq OWNER TO postgres;

--
-- TOC entry 4931 (class 0 OID 0)
-- Dependencies: 223
-- Name: dnevni_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dnevni_log_log_id_seq OWNED BY public.dnevni_log.log_id;


--
-- TOC entry 222 (class 1259 OID 24919)
-- Name: dogadaj; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dogadaj (
    dogadaj_id integer NOT NULL,
    biljka_id integer,
    datum date DEFAULT CURRENT_DATE,
    tip public.dogadaj_tip NOT NULL
);


ALTER TABLE public.dogadaj OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 24918)
-- Name: dogadaj_dogadaj_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dogadaj_dogadaj_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dogadaj_dogadaj_id_seq OWNER TO postgres;

--
-- TOC entry 4932 (class 0 OID 0)
-- Dependencies: 221
-- Name: dogadaj_dogadaj_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dogadaj_dogadaj_id_seq OWNED BY public.dogadaj.dogadaj_id;


--
-- TOC entry 226 (class 1259 OID 24945)
-- Name: podsjetnik; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.podsjetnik (
    podsjetnik_id integer NOT NULL,
    biljka_id integer,
    datum date NOT NULL,
    aktivnost public.dogadaj_tip NOT NULL
);


ALTER TABLE public.podsjetnik OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 24944)
-- Name: podsjetnik_podsjetnik_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.podsjetnik_podsjetnik_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.podsjetnik_podsjetnik_id_seq OWNER TO postgres;

--
-- TOC entry 4933 (class 0 OID 0)
-- Dependencies: 225
-- Name: podsjetnik_podsjetnik_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.podsjetnik_podsjetnik_id_seq OWNED BY public.podsjetnik.podsjetnik_id;


--
-- TOC entry 220 (class 1259 OID 24904)
-- Name: slika; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slika (
    slika_id integer NOT NULL,
    biljka_id integer,
    slikica bytea NOT NULL,
    opis text,
    datum timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.slika OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 24903)
-- Name: slika_slika_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slika_slika_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slika_slika_id_seq OWNER TO postgres;

--
-- TOC entry 4934 (class 0 OID 0)
-- Dependencies: 219
-- Name: slika_slika_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slika_slika_id_seq OWNED BY public.slika.slika_id;


--
-- TOC entry 227 (class 1259 OID 24976)
-- Name: ukupno_dogadaja; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.ukupno_dogadaja AS
 SELECT sum(
        CASE
            WHEN (tip = 'Zalijevanje'::public.dogadaj_tip) THEN 1
            ELSE 0
        END) AS zalijevanjecount,
    sum(
        CASE
            WHEN (tip = 'Prihranjivanje'::public.dogadaj_tip) THEN 1
            ELSE 0
        END) AS prihranjivanjecount,
    sum(
        CASE
            WHEN (tip = 'Presađivanje'::public.dogadaj_tip) THEN 1
            ELSE 0
        END) AS presadivanjecount
   FROM public.dogadaj;


ALTER VIEW public.ukupno_dogadaja OWNER TO postgres;

--
-- TOC entry 4730 (class 2604 OID 24887)
-- Name: biljka biljka_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.biljka ALTER COLUMN biljka_id SET DEFAULT nextval('public.biljka_biljka_id_seq'::regclass);


--
-- TOC entry 4732 (class 2604 OID 24897)
-- Name: biljka_povijest povijest_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.biljka_povijest ALTER COLUMN povijest_id SET DEFAULT nextval('public.biljka_povijest_povijest_id_seq'::regclass);


--
-- TOC entry 4738 (class 2604 OID 24935)
-- Name: dnevni_log log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dnevni_log ALTER COLUMN log_id SET DEFAULT nextval('public.dnevni_log_log_id_seq'::regclass);


--
-- TOC entry 4736 (class 2604 OID 24922)
-- Name: dogadaj dogadaj_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dogadaj ALTER COLUMN dogadaj_id SET DEFAULT nextval('public.dogadaj_dogadaj_id_seq'::regclass);


--
-- TOC entry 4740 (class 2604 OID 24948)
-- Name: podsjetnik podsjetnik_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podsjetnik ALTER COLUMN podsjetnik_id SET DEFAULT nextval('public.podsjetnik_podsjetnik_id_seq'::regclass);


--
-- TOC entry 4734 (class 2604 OID 24907)
-- Name: slika slika_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slika ALTER COLUMN slika_id SET DEFAULT nextval('public.slika_slika_id_seq'::regclass);


--
-- TOC entry 4912 (class 0 OID 24884)
-- Dependencies: 216
-- Data for Name: biljka; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.biljka (biljka_id, ime, vrsta, datum_sadnje, zalijevanje, prihranjivanje, presadivanje, min_temp, max_temp, min_vlaga, max_vlaga, dodatno) FROM stdin;
1	Ficus	Sobna biljka	2024-08-26	7	30	365	15	25	40	60	Zelena biljka, voli svjetlost
2	Aloe Vera	Sukulenta	2024-08-26	14	60	730	10	30	80	90	Ljekovita biljka, treba puno sunca
9	biljka1		2024-08-26	3	16	189	10	25	10	35	Voli sunce.
\.


--
-- TOC entry 4914 (class 0 OID 24894)
-- Dependencies: 218
-- Data for Name: biljka_povijest; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.biljka_povijest (povijest_id, biljka_id, ime, vrsta, datum_sadnje, zalijevanje, prihranjivanje, presadivanje, min_temp, max_temp, min_vlaga, max_vlaga, dodatno, operacija, vrijeme_zapisa) FROM stdin;
1	8	ana		2024-08-26	3	15	180	20	25	20	30		INSERT	2024-08-26 01:44:54.942176
2	8	ana2	vrsta	2024-08-19	3	15	180	20	25	20	30	azurirano	UPDATE	2024-08-26 01:46:26.225502
3	8	ana2	vrsta	2024-08-22	3	15	190	20	25	20	30	azurirano	UPDATE	2024-08-26 01:49:01.933754
4	8	ana2	vrsta	2024-08-22	3	15	190	20	25	20	39	azurirano	UPDATE	2024-08-26 02:17:40.133457
5	9	biljka1		2024-08-26	3	16	189	10	25	10	35	Voli sunce.	INSERT	2024-08-26 05:57:36.116377
\.


--
-- TOC entry 4920 (class 0 OID 24932)
-- Dependencies: 224
-- Data for Name: dnevni_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dnevni_log (log_id, biljka_id, temperaturadanas, vlagadanas, datum) FROM stdin;
1	1	20.5	50	2024-08-26 01:10:43.639767
2	2	28	30	2024-08-26 01:10:43.639767
6	9	15	20	2024-08-26 05:58:32.660085
\.


--
-- TOC entry 4918 (class 0 OID 24919)
-- Dependencies: 222
-- Data for Name: dogadaj; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dogadaj (dogadaj_id, biljka_id, datum, tip) FROM stdin;
1	1	2024-08-26	Zalijevanje
2	2	2024-08-26	Prihranjivanje
5	2	2024-08-25	Zalijevanje
8	1	2024-08-26	Presađivanje
9	9	2024-08-26	Zalijevanje
\.


--
-- TOC entry 4922 (class 0 OID 24945)
-- Dependencies: 226
-- Data for Name: podsjetnik; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.podsjetnik (podsjetnik_id, biljka_id, datum, aktivnost) FROM stdin;
1	1	2024-09-02	Zalijevanje
2	2	2024-10-25	Prihranjivanje
3	2	2024-09-08	Zalijevanje
6	1	2025-08-26	Presađivanje
7	9	2024-08-29	Zalijevanje
\.


--
-- TOC entry 4916 (class 0 OID 24904)
-- Dependencies: 220
-- Data for Name: slika; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slika (slika_id, biljka_id, slikica, opis, datum) FROM stdin;
\.


--
-- TOC entry 4935 (class 0 OID 0)
-- Dependencies: 215
-- Name: biljka_biljka_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.biljka_biljka_id_seq', 9, true);


--
-- TOC entry 4936 (class 0 OID 0)
-- Dependencies: 217
-- Name: biljka_povijest_povijest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.biljka_povijest_povijest_id_seq', 5, true);


--
-- TOC entry 4937 (class 0 OID 0)
-- Dependencies: 223
-- Name: dnevni_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dnevni_log_log_id_seq', 6, true);


--
-- TOC entry 4938 (class 0 OID 0)
-- Dependencies: 221
-- Name: dogadaj_dogadaj_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dogadaj_dogadaj_id_seq', 9, true);


--
-- TOC entry 4939 (class 0 OID 0)
-- Dependencies: 225
-- Name: podsjetnik_podsjetnik_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.podsjetnik_podsjetnik_id_seq', 7, true);


--
-- TOC entry 4940 (class 0 OID 0)
-- Dependencies: 219
-- Name: slika_slika_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slika_slika_id_seq', 3, true);


--
-- TOC entry 4742 (class 2606 OID 24892)
-- Name: biljka biljka_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.biljka
    ADD CONSTRAINT biljka_pkey PRIMARY KEY (biljka_id);


--
-- TOC entry 4744 (class 2606 OID 24902)
-- Name: biljka_povijest biljka_povijest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.biljka_povijest
    ADD CONSTRAINT biljka_povijest_pkey PRIMARY KEY (povijest_id);


--
-- TOC entry 4750 (class 2606 OID 24938)
-- Name: dnevni_log dnevni_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dnevni_log
    ADD CONSTRAINT dnevni_log_pkey PRIMARY KEY (log_id);


--
-- TOC entry 4748 (class 2606 OID 24925)
-- Name: dogadaj dogadaj_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dogadaj
    ADD CONSTRAINT dogadaj_pkey PRIMARY KEY (dogadaj_id);


--
-- TOC entry 4752 (class 2606 OID 24950)
-- Name: podsjetnik podsjetnik_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podsjetnik
    ADD CONSTRAINT podsjetnik_pkey PRIMARY KEY (podsjetnik_id);


--
-- TOC entry 4746 (class 2606 OID 24912)
-- Name: slika slika_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slika
    ADD CONSTRAINT slika_pkey PRIMARY KEY (slika_id);


--
-- TOC entry 4757 (class 2620 OID 24957)
-- Name: biljka biljezi_promjene_biljka; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER biljezi_promjene_biljka AFTER INSERT OR UPDATE ON public.biljka FOR EACH ROW EXECUTE FUNCTION public.zapisivanje_povijesti_biljke();


--
-- TOC entry 4758 (class 2620 OID 24959)
-- Name: biljka min_max_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER min_max_trigger BEFORE INSERT OR UPDATE ON public.biljka FOR EACH ROW EXECUTE FUNCTION public.min_max();


--
-- TOC entry 4759 (class 2620 OID 24965)
-- Name: biljka provjeri_azuriranje_biljke_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER provjeri_azuriranje_biljke_trigger BEFORE UPDATE ON public.biljka FOR EACH ROW EXECUTE FUNCTION public.provjeri_azuriranje_biljke();


--
-- TOC entry 4760 (class 2620 OID 24963)
-- Name: biljka provjeri_biljku_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER provjeri_biljku_trigger BEFORE INSERT OR UPDATE ON public.biljka FOR EACH ROW EXECUTE FUNCTION public.provjeri_biljku();


--
-- TOC entry 4762 (class 2620 OID 24973)
-- Name: dogadaj provjeri_datum_dogadaja_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER provjeri_datum_dogadaja_trigger BEFORE INSERT ON public.dogadaj FOR EACH ROW EXECUTE FUNCTION public.provjeri_datum_dogadaja();


--
-- TOC entry 4766 (class 2620 OID 24975)
-- Name: podsjetnik provjeri_datum_podsjetnika_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER provjeri_datum_podsjetnika_trigger BEFORE INSERT OR UPDATE ON public.podsjetnik FOR EACH ROW EXECUTE FUNCTION public.provjeri_datum_podsjetnika();


--
-- TOC entry 4765 (class 2620 OID 24967)
-- Name: dnevni_log provjeri_dnevni_log_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER provjeri_dnevni_log_trigger BEFORE INSERT ON public.dnevni_log FOR EACH ROW EXECUTE FUNCTION public.provjeri_dnevni_log();


--
-- TOC entry 4763 (class 2620 OID 24971)
-- Name: dogadaj provjeri_dodavanje_dogadaja_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER provjeri_dodavanje_dogadaja_trigger BEFORE INSERT ON public.dogadaj FOR EACH ROW EXECUTE FUNCTION public.provjeri_dodavanje_dogadaja();


--
-- TOC entry 4761 (class 2620 OID 24961)
-- Name: slika provjeri_sliku_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER provjeri_sliku_trigger BEFORE INSERT OR UPDATE ON public.slika FOR EACH ROW EXECUTE FUNCTION public.provjeri_sliku();


--
-- TOC entry 4764 (class 2620 OID 24969)
-- Name: dogadaj stvori_podsjetnik_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER stvori_podsjetnik_trigger AFTER INSERT OR UPDATE ON public.dogadaj FOR EACH ROW EXECUTE FUNCTION public.stvori_podsjetnik();


--
-- TOC entry 4755 (class 2606 OID 24939)
-- Name: dnevni_log dnevni_log_biljka_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dnevni_log
    ADD CONSTRAINT dnevni_log_biljka_id_fkey FOREIGN KEY (biljka_id) REFERENCES public.biljka(biljka_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4754 (class 2606 OID 24926)
-- Name: dogadaj dogadaj_biljka_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dogadaj
    ADD CONSTRAINT dogadaj_biljka_id_fkey FOREIGN KEY (biljka_id) REFERENCES public.biljka(biljka_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4756 (class 2606 OID 24951)
-- Name: podsjetnik podsjetnik_biljka_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podsjetnik
    ADD CONSTRAINT podsjetnik_biljka_id_fkey FOREIGN KEY (biljka_id) REFERENCES public.biljka(biljka_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4753 (class 2606 OID 24913)
-- Name: slika slika_biljka_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slika
    ADD CONSTRAINT slika_biljka_id_fkey FOREIGN KEY (biljka_id) REFERENCES public.biljka(biljka_id) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2024-08-26 07:21:36

--
-- PostgreSQL database dump complete
--


create or replace PACKAGE PKG_STRUK_TRANS AS 

  
 --PROCEDURE wpis_do_pliku(p_tekst varchar2,p_nazwa_pliku varchar2);
 --FUNCTION NEW_KOD_INDEKS1(p_kod_old IN varchar2) RETURN VARCHAR2;
 PROCEDURE SURZAM_PODMIANA(tryb IN NUMBER);
 PROCEDURE SPISZ_PODMIANA(tryb IN NUMBER);
 PROCEDURE KARTOTEKA_PODMIANA(tryb IN NUMBER);
 PROCEDURE KATALOG_PODMIANA(tryb IN NUMBER);
 PROCEDURE SPISS_PODMIANA(tryb IN NUMBER);
 PROCEDURE BRAKI_B_PODMIANA(tryb IN NUMBER);
 PROCEDURE OPT_NR_PODMIANA(tryb IN NUMBER); 
 PROCEDURE OPT_TAF_PODMIANA(tryb IN NUMBER); 
 PROCEDURE paml303_PODMIANA(tryb IN NUMBER);
 PROCEDURE paml66_PODMIANA(tryb IN NUMBER);
 PROCEDURE str_w_zlec_PODMIANA(tryb IN NUMBER);
 PROCEDURE WYKZAL_PODMIANA(tryb IN NUMBER);
 PROCEDURE CR_DATA_PODMIANA(tryb IN NUMBER);
 PROCEDURE CR_RESULTS_PODMIANA(tryb IN NUMBER);
 PROCEDURE L_WYC_PODMIANA(tryb IN NUMBER);
 PROCEDURE KARTOTEKA_PODMIANA2(tryb IN NUMBER);
 PROCEDURE KATALOG_INST_PODMIANA;

END PKG_STRUK_TRANS;
/

create or replace PACKAGE BODY PKG_STRUK_TRANS AS

--v_date DATE;



---------------------------PRZED UTWORZENIEM NALEZY STWORZYC DIARECTORY O NAZWIE STRUK_TRANS!!!!!!!!!!!!---------------
procedure wpis_do_pliku
  (p_tekst varchar2,p_nazwa_pliku varchar2)
IS
  fileHandler UTL_FILE.FILE_TYPE;
BEGIN
  fileHandler := UTL_FILE.FOPEN('STRUK_TRANS',p_nazwa_pliku,'a');
  UTL_FILE.PUTF(fileHandler,p_tekst);
  UTL_FILE.FCLOSE(fileHandler);
EXCEPTION
  WHEN utl_file.invalid_path THEN
     raise_application_error(-20000, 'ERROR: Invalid PATH FOR file.');
  WHEN OTHERS THEN
    SYS.DBMS_OUTPUT.PUT_LINE('Error utl_file:'||SQLCODE);
    

END wpis_do_pliku;

------------------------------------------------------------------------------------------------------------------------





----------------------funkcja ktora zwraca nowy nr_inst po daniu kod_new



FUNCTION NR_INST_NEW
(p_nr_kat number)
RETURN number
IS
v_nr_inst_new number(3);
BEGIN

    SELECT nr_napisu INTO v_nr_inst_new FROM
        (SELECT nr_napisu FROM struk_trans 
         WHERE nr_odd=(SELECT nr_odz FROM firma) AND typ=1 AND  nr_new=p_nr_kat 
         ORDER BY nr_new)
    WHERE rownum=1;

RETURN v_nr_inst_new;

END NR_INST_NEW;


-----------------------------------------------------------------------------------------------------------------------


----------------------FUNKCJA KTORE PO OTRZYMANIU STAREGO KOD_STR SWROCI NOWY KOD_STR--------------------------------------
FUNCTION NEW_KOD_INDEKS1
(p_kod_old IN varchar2)
return varchar2
IS
v_kod_new spisz.kod_str%TYPE;
wyjscie struk_trans%rowtype;

begin



select kod_new into v_kod_new from(
      select kod_new,nr_new 
      from struk_trans 
      where NR_ODD=(select nr_odz from firma) and KOD_OLD=p_kod_old and typ=3 order by nr_new) 
where rownum=1;

return v_kod_new;

end NEW_KOD_INDEKS1;
-------------------------------------------------------------------------------------------------------------------------------


----------------------FUNKCJA KTORE PO OTRZYMANIU STAREGO NR_KOM_STR SWROCI NOWY NR str--------------------------------------------

FUNCTION NEW_NR_INDEKS
(p_nr_old IN numeric)
return numeric
IS
v_nr_new struktury.nr_kom_str%TYPE; 
v_struk_trans struk_trans%ROWTYPE;

BEGIN

  SELECT nr_new INTO v_nr_new 
  FROM
      (SELECT  nr_new
       FROM struk_trans
       WHERE NR_ODD=(select nr_odz from firma) and nr_old=p_nr_old and typ=3 order by nr_new)
  WHERE rownum=1; 
  
  
RETURN v_nr_new;


END NEW_NR_INDEKS;
------------------------------------------------------------------------------------------------------------------------


----------------------FUNKCJA KTORE PO OTRZYMANIU STAREGO INDEKSU kartoteki SWROCI NOWY indeks---------------------------
 function NEW_INDEKS_KARTOTEKA
(p_indeks_kart varchar2)
RETURN varchar2
IS
v_indeks_new kartoteka.indeks%TYPE;
BEGIN

    SELECT kod_new INTO v_indeks_new FROM
        (SELECT s.kod_new,k.nr_kat FROM struk_trans s
         INNER JOIN kartoteka k
         ON s.kod_new=k.indeks
         WHERE s.nr_odd=(SELECT nr_odz FROM firma) AND s.typ=2 AND  s.kod_old=p_indeks_kart
         ORDER BY k.nr_kat)
    WHERE rownum=1;

RETURN v_indeks_new;

END NEW_INDEKS_KARTOTEKA;

-----------------------------------------------------------------------------------------------------------------------


----------------------PROCEDURA KTORA PO OTRZYMANIU STAREGO nr_katalogu SWROCI NOWY nr_kat(nr_new) z struk_trans je¿eli 
--bêdzie kilka nowych rekordów w  tabei przejsc to wybierze ten rekord który ma najni¿szy nr_new-------------------------



FUNCTION NEW_NR_KAT
(p_nr_kat varchar2)
RETURN varchar2
IS
v_nr_kat_new katalog.nr_kat%TYPE;
BEGIN

    SELECT nr_new INTO v_nr_kat_new FROM
        (SELECT nr_new FROM struk_trans 
         WHERE nr_odd=(SELECT nr_odz FROM firma) AND typ=1 AND  nr_old=p_nr_kat
         ORDER BY nr_new)
    WHERE rownum=1;

RETURN v_nr_kat_new;

END NEW_NR_KAT;


-----------------------------------------------------------------------------------------------------------------------



----------------------PROCEDURA KTORA PO OTRZYMANIU nowego nr_katalogu SWROCI stary nr_kat(nr_old) z struk_trans je¿eli 
--bêdzie kilka nowych rekordów w  tabei przejsc to wybierze ten rekord który ma najni¿szy nr_new-------------------------



FUNCTION OLD_NR_KAT
(p_nr_kat varchar2)
RETURN varchar2
IS
v_nr_kat_old katalog.nr_kat%TYPE;
BEGIN

    SELECT nr_old INTO v_nr_kat_old FROM
        (SELECT nr_old FROM struk_trans 
         WHERE nr_odd=(SELECT nr_odz FROM firma) AND typ=1 AND  nr_new=p_nr_kat
         ORDER BY nr_old)
    WHERE rownum=1;

RETURN v_nr_kat_old;

END OLD_NR_KAT;


-----------------------------------------------------------------------------------------------------------------------










----------------------PROCEDURA KTORA PO OTRZYMANIU STAREGO indeksu(kat) SWROCI NOWY indesks(kod_new) z struk_trans je¿eli 
--bêdzie kilka nowych rekordów w  tabei przejsc to wybierze ten rekord który ma najni¿szy nr_new-------------------------



FUNCTION NEW_INDEKS_KATALOG
(p_indeks varchar2)
RETURN varchar2
IS
v_nr_kat_new katalog.nr_kat%TYPE;
v_indeks_new katalog.typ_kat%TYPE;
BEGIN

    SELECT kod_new INTO v_indeks_new FROM
        (SELECT kod_new FROM struk_trans 
         WHERE nr_odd=(SELECT nr_odz FROM firma) AND typ=1 AND  kod_old=p_indeks
         ORDER BY nr_new)
    WHERE rownum=1;

RETURN v_indeks_new;

END NEW_INDEKS_KATALOG;


-----------------------------------------------------------------------------------------------------------------------



----------------zamiana indeksu(kartoteka) oraz nr_kat(katalog) oraz sprawdzenie zgodnoœci nr_kat w Kartotece----------------------------------------------------------------------------------------

procedure SURZAM_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20) ;
v_surzam surzam%ROWTYPE;
v_kod_new surzam.indeks%TYPE;
v_nr_kat surzam.nr_kat%TYPE;
v_blad number(2);
CURSOR kursor IS SELECT * FROM surzam  ;

BEGIN
--UTL_FILE.FREMOVE ('MARCIN','surzam.txt');
SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') "NOW" INTO v_date FROM DUAL;
IF tryb=1 THEN
    wpis_do_pliku('UPDATE',v_date||'surzam.txt');
END IF;

EXECUTE IMMEDIATE 'ALTER TRIGGER SURZAM_ON_CHANGE DISABLE';

  OPEN kursor;
    
      LOOP
      
          FETCH kursor INTO  v_surzam ;
          EXIT WHEN kursor%NOTFOUND; 
            BEGIN
                
                v_nr_kat := 0;
                --v_kod_new := NEW_INDEKS_KARTOTEKA(v_surzam.indeks);
                v_nr_kat := NEW_NR_KAT(v_surzam.nr_kat);
                
                --dbms_output.put_line('kod_old ' ||v_surzam.indeks|| ' kod_new '||v_kod_new||' nr_kat ' ||v_nr_kat);
				
				IF tryb=1 THEN
        
         --wpis_do_pliku('JESTEM W UPDATE',v_date||'surzam.txt');
             
            IF v_surzam.nr_kat <> v_nr_kat THEN
                UPDATE surzam
                   SET
                      --indeks=v_kod_new,
                      nr_kat=v_nr_kat
                   WHERE
                      
                      NR_MAG=v_surzam.NR_MAG AND
                      NR_KAT=v_surzam.NR_KAT AND
                      indeks=v_surzam.indeks AND
                      TYP_ZLEC=V_SURZAM.TYP_ZLEC AND
                      NR_ZLEC=V_SURZAM.NR_ZLEC;
            END IF;
			    END IF;
            
                  --wpis_do_pliku('kod_old ' ||v_surzam.indeks|| ' kod_new '||v_kod_new||' nr_kat ' ||v_nr_kat,v_date||'surzam.txt');
                
                
                /* SELECT COUNT(1) INTO v_blad
                 FROM KARTOTEKA
                 WHERE 
                      indeks = v_kod_new AND 
                      nr_kat = v_nr_kat;
                      
                IF v_blad=0 THEN
                
                
                      v_counter2 := v_counter2 +1;
                  
                  IF v_counter2 = 1 THEN
                        wpis_do_pliku( 'indeks'||CHR(9)||'nr_zlec'||CHR(9)||'nr_kat'||CHR(9)||
                        'indes_new'||CHR(9)||'nr_kat_new'||CHR(9)||'bledy',v_date||'surzam.txt');

                  END IF;
                
                      wpis_do_pliku(v_surzam.indeks||CHR(9)||v_surzam.nr_zlec||CHR(9)||v_surzam.nr_kat
                      ||CHR(9)||v_kod_new||CHR(9)||v_nr_kat||CHR(9)||
                      'Niezgodnosc nr_kat z SURZAM(z indeks_new)z nr_kat z Kartoteki'
                      ,v_Date||'surzam.txt');
                END IF;*/
                      
             
            
            EXCEPTION
                  WHEN OTHERS THEN
                  
                  v_counter2 := v_counter2 +1;
                  
                  IF v_counter2 = 1 THEN
                        wpis_do_pliku( 'indeks'||CHR(9)||'nr_zlec'||CHR(9)||'nr_kat'||CHR(9)||
                        'nr_kat_new'||CHR(9)||'bledy',v_date||'surzam.txt');

                  END IF;
                  
                  err_num := SQLCODE;
                  if err_num=-1 then
                      /*DBMS_OUTPUT.PUT_LINE('unikalny indeks ' ||v_surzam.indeks||
                      ' o nr_zlec:'||v_surzam.nr_zlec|| ' nr_kat' ||v_surzam.nr_kat ||
                      ' indes_new '||v_kod_new|| ' nr_kat_new '||v_nr_kat||' numer bledu:'||err_num);*/
        
                      wpis_do_pliku(v_surzam.indeks||CHR(9)||v_surzam.nr_zlec||CHR(9)||v_surzam.nr_kat
                      ||CHR(9)||v_nr_kat||CHR(9)||'dukplicate indeks' ,v_Date||'surzam.txt');
                  
                  ELSIF err_num=100 THEN
                     /*    DBMS_OUTPUT.PUT_LINE('brak nowego indeksy dla ' ||v_surzam.indeks||
                      ' o nr_zlec:'||v_surzam.nr_zlec|| ' nr_kat' ||v_surzam.nr_kat ||
                      ' indes_new '||v_kod_new|| ' nr_kat_new '||v_nr_kat||' numer bledu:'||err_num);*/
                      
                      wpis_do_pliku(v_surzam.indeks||CHR(9)||v_surzam.nr_zlec||CHR(9)||v_surzam.nr_kat
                      ||CHR(9)||CHR(9)||'nie znaleziono nr_kat w tab przejœæ' ,v_date||'surzam.txt');
                      
                  ELSE    
                      wpis_do_pliku(v_surzam.indeks||CHR(9)||v_surzam.nr_zlec||CHR(9)||v_surzam.nr_kat
                      ||CHR(9)||v_nr_kat||CHR(9)||SUBSTR(SQLERRM, 1 , 64) ,v_Date||'surzam.txt');
                  END IF;

            END;
            
     
            v_counter := v_counter + 1;
      END LOOP;
  CLOSE  kursor;
    
    
v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||to_char(v_counter2-1)||'  data '||v_date );


if v_counter<>0 then
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter-1 )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2-1)||'  data '||v_date ,v_date||'surzam.txt');
else
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2)||'  data '||v_date ,v_date||'surzam.txt');
end if;
EXECUTE IMMEDIATE 'ALTER TRIGGER SURZAM_ON_CHANGE ENABLE';

END SURZAM_PODMIANA;
------------------------------------------------------------------------------------------------------------------------------------







-------------------------------------------konwersja SPISZ(KOD_STR)----------------------------------------------------
procedure SPISZ_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20) ;

v_spisz spisz%rowtype;
--v_kod_str_old spisz.kod_str%TYPE;
v_kod_new spisz.kod_str%TYPE;

CURSOR kursor IS SELECT * FROM spisz FOR UPDATE of kod_str ;


BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') "NOW" INTO v_date FROM DUAL;



IF tryb=1 THEN
 wpis_do_pliku('UPDATE',v_date||'spisz.txt');
END IF; 
wpis_do_pliku('nr_zlec'||CHR(9)||'kod_str'||CHR(9)||
'nr_kom_zlec'||CHR(9)||'kod_new'||CHR(9)||'bledy',v_date||'spisz.txt');

EXECUTE IMMEDIATE 'ALTER TRIGGER SPISZ_ON_CHANGE DISABLE';

    OPEN kursor;
    
      LOOP
            FETCH kursor INTO v_spisz;
            EXIT WHEN kursor%NOTFOUND;  
              BEGIN
              
                v_kod_new := ' ';
                v_counter := v_counter + 1;
                v_kod_new:=new_kod_indeks1(v_spisz.kod_str);
                --dbms_output.put_line(' kod_old '||v_spisz.kod_str);
                
        
            
				IF tryb=1 THEN
        
         --wpis_do_pliku('JESTEM W UPDATE',v_date||'spisz.txt');
           
                UPDATE spisz
                             SET  
                                 kod_str=v_kod_new
                             WHERE CURRENT OF kursor;
                                 /*kod_str=v_spisz.kod_str AND
                                 nr_poz=v_spisz.nr_poz AND
                                 nR_KOM_ZLEC=v_spisz.NR_KOM_ZLEC;*/
                                 
                                 
--Pozdok kolumna indeks tylko dla mag 3 i kol_dod=0 ze spisz link po pozdok.nr_komp_baz= spisz.nr_kom_zlec 
--and pozdok.nr_poz_zlec= spisz.poz
                           
                UPDATE pozdok  
                SET
                    indeks = v_kod_new
                WHERE 
                    nr_komp_baz = v_spisz.nr_kom_zlec AND 
                    nr_poz_zlec = v_spisz.nr_poz AND
                    kol_dod = 0 AND
                    (nr_mag = 3 OR nr_mag=7) AND 
                    storno = 0;
                             
    
    --Pokartot - indeks dla mag=3 ze spisz wg link pozkartot.nr_komp_zlec= spisz.nr_kom_zlec 
    --and pozkartot.nr_poz_zlec= spisz.poz
    
    
                  UPDATE pozkartot
                  SET
                     indeks = v_kod_new
                  WHERE
                     (nr_mag = 3 OR nr_mag=7) AND
                     NR_KOMP_ZLEC = v_spisz.nr_kom_zlec AND
                     NR_POZ_ZLEC = v_spisz.nr_poz;



--Fakpoz kol indeks tylko dla mag 3 ze spisz wg link fakpoz.id_zlec= spisz.nr_kom_zlec 
--and fakpoz.id_zlec_poz= spisz.poz

                  UPDATE fakpoz
                  SET
                    indeks = v_kod_new
                  WHERE
                    id_zlec= V_spisz.nr_kom_zlec AND 
                    id_zlec_poz= V_spisz.nr_poz AND 
                    nr_mag = 3 ;
    
        END IF;

               EXCEPTION
                   WHEN OTHERS THEN
                  
                  v_counter2 := v_counter2 +1;
                  
                 /* IF v_counter2 = 1 THEN
                        wpis_do_pliku('nr_zlec'||CHR(9)||'kod_str'||CHR(9)||
                        'nr_kom_zlec'||CHR(9)||'kod_new'||CHR(9)||'bledy',v_date||'spisz.txt');

                  END IF;*/
                  
                  err_num := SQLCODE;
                  IF err_num=-1 THEN
                     /* DBMS_OUTPUT.PUT_LINE('unikalny indeks ' ||v_spisz.kod_str||
                      ' o nr_zlec:'||v_spisz.nr_zlec|| ' nr_kom_str' ||v_spisz.nr_kom_zlec||'kod_new'||v_kod_new||
                      ' blad:dukplicate indeks');*/
        
                      wpis_do_pliku(v_spisz.nr_zlec||CHR(9)||v_spisz.kod_str||CHR(9)||v_spisz.nr_kom_zlec
                      ||CHR(9)||V_KOD_NEW||'dukplicate indeks' ,v_Date||'spisz.txt');
                  
                  ELSIF err_num=100 THEN
                     /*    DBMS_OUTPUT.PUT_LINE('brak nowego indeksy dla ' ||v_spisz.indeks||
                      ' o nr_zlec:'||v_spisz.nr_zlec|| ' nr_kat' ||v_spisz.nr_kat ||
                      ' indes_new '||v_kod_new|| ' nr_kat_new '||v_nr_kat||' numer bledu:'||err_num);*/
                      
                      wpis_do_pliku(v_spisz.nr_zlec||CHR(9)||v_spisz.kod_str||CHR(9)||v_spisz.nr_kom_zlec
                      ||CHR(9)||CHR(9)||'Nie znaleziono kod_str w tabeli przejsc' ,v_Date||'spisz.txt');
                  ELSE   
                      wpis_do_pliku(v_spisz.nr_zlec||CHR(9)||v_spisz.kod_str||CHR(9)||v_spisz.nr_kom_zlec
                      ||CHR(9)||V_KOD_NEW||chr(9)||SUBSTR(SQLERRM, 1 , 64) ,v_Date||'spisz.txt');
                  END IF;
                                              
                                              
               END;         

            --EXIT WHEN kursor%NOTFOUND;   
             
         
       END LOOP;
     
    CLOSE kursor;
      
      
      
v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter-1 ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.');



if v_counter<>0 then
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter-1 )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2-1)||'  data '||v_date ,v_date||'spisz.txt');
else
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2)||'  data '||v_date ,v_date||'spisz.txt');
end if;
EXECUTE IMMEDIATE 'ALTER TRIGGER SPISZ_ON_CHANGE ENABLE';

END SPISZ_PODMIANA;  

-----------------------------------------------------------------------------------------------------------------------------------------

--------------------------------podmiana nr_kat w kartotece----------------------------------------------------------------------
PROCEDURE KARTOTEKA_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20) ;


v_kartoteka kartoteka%rowtype;

v_nr_kat kartoteka.nr_kat%TYPE;


CURSOR kursor IS SELECT * FROM kartoteka WHERE  (nr_mag<>3 or nr_mag<>7)   
                                           FOR UPDATE of nr_kat;

BEGIN


  SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') "NOW" INTO v_date FROM DUAL;
IF tryb=1 THEN
        
         wpis_do_pliku('UPDATE',v_date||'kartoteka.txt');
END IF;
wpis_do_pliku('indeks'||CHR(9)||'zn_kart'||CHR(9)||
'nr_odz'||CHR(9)||'nr_mag'||CHR(9)||'nr_kat'||CHR(9)||'nr_kat_new'||chr(9)
||'bledy',v_date||'kartoteka.txt');
    OPEN kursor;
    
      LOOP
            FETCH kursor INTO v_kartoteka;
             EXIT WHEN kursor%NOTFOUND;  
              BEGIN
                v_counter := v_counter + 1;
                v_nr_kat := 0;
                
                
                
      IF v_kartoteka.nr_kat<>0 THEN
                v_nr_kat:=new_nr_kat(v_kartoteka.nr_kat);
                --dbms_output.put_line(' kod_old '||v_spisz.kod_str);
 
 
            
				IF tryb=1 THEN
        
         --wpis_do_pliku('JESTEM W UPDATE',v_date||'spisz.txt');
            IF v_kartoteka.nr_kat <> v_nr_kat THEN
                UPDATE kartoteka
                             SET  
                                 nr_kat=v_nr_kat
                             WHERE
                                 CURRENT OF kursor;
            END IF;
                                 
        END IF;
        
      END IF;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      v_counter2 := v_counter2 +1;
                      wpis_do_pliku(v_kartoteka.indeks||CHR(9)||v_kartoteka.zn_kart||CHR(9)||v_kartoteka.nr_odz
                      ||CHR(9)||V_KARTOTEKA.NR_MAG||CHR(9)||v_kartoteka.nr_kat||chr(9)||chr(9)||'NIE ZNALEZIONO NR_KAT W TAB PRZEJSC' ,v_Date||'kartoteka.txt');
                   WHEN DUP_VAL_ON_INDEX THEN 
                      v_counter2 := v_counter2 +1;
                      wpis_do_pliku(v_kartoteka.indeks||CHR(9)||v_kartoteka.zn_kart||CHR(9)||v_kartoteka.nr_odz
                      ||CHR(9)||v_kartoteka.NR_MAG||CHR(9)||v_kartoteka.nr_kat||chr(9)||v_nr_kat||'dukplicate indeks' ,v_Date||'kartoteka.txt');
                   WHEN OTHERS THEN   
                      v_counter2 := v_counter2 +1;
                       wpis_do_pliku(v_kartoteka.indeks||CHR(9)||v_kartoteka.zn_kart||CHR(9)||v_kartoteka.nr_odz
                      ||CHR(9)||v_kartoteka.NR_MAG||CHR(9)||v_kartoteka.nr_kat||chr(9)||v_nr_kat||SUBSTR(SQLERRM, 1 , 64) ,v_Date||'kartoteka.txt');                           
               END;           
       END LOOP;  
    CLOSE kursor;
      
      
      
v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.');



--if v_counter<>0 then
--wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter-1 )
--||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2-1)||'  data '||v_date ,v_date||'kartoteka.txt');
--else
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2)||'  data '||v_date ,v_date||'kartoteka.txt');
--end if;
END KARTOTEKA_PODMIANA;  
--------------------------------------------------------------------------------------------------------------------------------





--------------------------------podmiana indeksu(struktury, dla mag=3 i mag=7) oraz gr_tow,nr_anal,nr_komp_gr(dla nowegeo indeksu który znajduje siê w strukturach) w kartotece----------------------------------------------------------------------
PROCEDURE KARTOTEKA_PODMIANA2(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20) ;


v_kartoteka kartoteka%rowtype;

v_nr_kat kartoteka.nr_kat%TYPE;
v_indeks kartoteka.indeks%TYPE;
v_gr_tow kartoteka.gr_tow%TYPE;
v_nr_anal kartoteka.nr_anal%TYPE;
v_nr_komp_gr kartoteka.nr_komp_gr%TYPE;
v_nazwa kartoteka.nazwa%TYPE;

CURSOR kursor IS SELECT * FROM kartoteka 
                          WHERE (nr_mag=3 or nr_mag=7) --and (indeks='EMALIOWANIE' or indeks='HARTOWANIE' or indeks='FPSC06N\HA')
                          FOR UPDATE of indeks, gr_tow, nr_anal, nr_komp_gr, akt, nazwa ;

BEGIN


  SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') "NOW" INTO v_date FROM DUAL;
IF tryb=1 THEN
        
         wpis_do_pliku('UPDATE',v_date||'kartoteka2.txt');
END IF;
wpis_do_pliku('indeks'||CHR(9)||'nr_anal'||CHR(9)||
'gr_tow'||CHR(9)||'nr_komp_gr'||CHR(9)||'indeks_new'||CHR(9)
||'nr_anal_new'||chr(9)||'new_nr_komp_tow'||chr(9)||'new_gr_tow'||chr(9)
||'bledy'||chr(9)||'Podmiana indeksu,gr_tow,nr_anal,nr_komp_gr,nazwa,akt=0',v_date||'kartoteka2.txt');
    OPEN kursor;
    
      LOOP
            FETCH kursor INTO v_kartoteka;
             EXIT WHEN kursor%NOTFOUND;  
              BEGIN
                v_nazwa := ' ';
                v_counter := v_counter + 1;
                v_nr_kat := -1; 
                v_indeks := ' ';
                v_gr_tow := ' ';
                v_nr_anal := -1;
                v_nr_komp_gr := -1;
                
                BEGIN
                  v_indeks := new_kod_indeks1(v_kartoteka.indeks);
                  
                 EXCEPTION  
                   WHEN NO_DATA_FOUND THEN
                      v_counter2 := v_counter2 +1;
                      wpis_do_pliku(v_kartoteka.indeks||CHR(9)||v_kartoteka.nr_anal||CHR(9)||v_kartoteka.gr_tow
                      ||CHR(9)||V_KARTOTEKA.nr_komp_gr||CHR(9)||v_indeks||chr(9)||v_nr_anal||
                      chr(9)||v_nr_komp_gr||chr(9)||v_gr_tow||chr(9)||'NIE ZNALEZIONO INDKESU W TAB PRZEJSC(TYP=3)' ,v_Date||'kartoteka2.txt');
                      continue;
                      
                      
                   
                   WHEN OTHERS THEN   
                      v_counter2 := v_counter2 +1;
                        wpis_do_pliku(v_kartoteka.indeks||CHR(9)||v_kartoteka.nr_anal||CHR(9)||v_kartoteka.gr_tow
                      ||CHR(9)||V_KARTOTEKA.nr_komp_gr||CHR(9)||v_indeks||chr(9)||v_nr_anal||
                      chr(9)||v_nr_komp_gr||chr(9)||v_gr_tow||chr(9)||SUBSTR(SQLERRM, 1 , 64) ,v_Date||'kartoteka2.txt');  
                      continue;
                      
                       
                    --continue;
                    end;
                  
                --wpis_do_pliku('JESTEM ',v_date||'kartoteka2.txt');
                --dbms_output.put_line(' kod_old '||v_spisz.kod_str);
                
                SELECT nr_anal, nr_komp_gr, gr_tow, naz_str 
                INTO v_nr_anal, v_nr_komp_gr, v_gr_tow, v_nazwa
                FROM struktury
                WHERE kod_str = v_indeks;
                
            
				IF tryb=1 THEN
        
         --wpis_do_pliku('JESTEM W UPDATE',v_date||'spisz.txt');
            
                UPDATE kartoteka
                             SET  
                                 indeks = v_indeks,
                                 nr_anal = v_nr_anal,
                                 nr_komp_gr = v_nr_komp_gr,
                                 gr_tow = v_gr_tow,
                                 nazwa = v_nazwa,
                                 akt = 0
                             WHERE 
                                 CURRENT OF kursor;
            
                                 
        END IF;
                 

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      v_counter2 := v_counter2 +1;
                      wpis_do_pliku(v_kartoteka.indeks||CHR(9)||v_kartoteka.nr_anal||CHR(9)||v_kartoteka.gr_tow
                      ||CHR(9)||V_KARTOTEKA.nr_komp_gr||CHR(9)||v_indeks||chr(9)||v_nr_anal||
                      chr(9)||v_nr_komp_gr||chr(9)||v_gr_tow||chr(9)||'NIE ZNALEZIONO NOWEGO INDEKSU W STRUKTURACH' ,v_Date||'kartoteka2.txt');
                   WHEN DUP_VAL_ON_INDEX THEN 
                      v_counter2 := v_counter2 +1;
                      wpis_do_pliku(v_kartoteka.indeks||CHR(9)||v_kartoteka.nr_anal||CHR(9)||v_kartoteka.gr_tow
                      ||CHR(9)||V_KARTOTEKA.nr_komp_gr||CHR(9)||v_indeks||chr(9)||v_nr_anal||
                      chr(9)||v_nr_komp_gr||chr(9)||v_gr_tow||chr(9)||'dany nowy indeks(DUPLICATE UNIQUE INDEKS) znajduje siê ju¿ w kartotece wiêc zostaje nie zmieniony' ,v_Date||'kartoteka2.txt');

                   WHEN OTHERS THEN   
                      v_counter2 := v_counter2 +1;
                        wpis_do_pliku(v_kartoteka.indeks||CHR(9)||v_kartoteka.nr_anal||CHR(9)||v_kartoteka.gr_tow
                      ||CHR(9)||V_KARTOTEKA.nr_komp_gr||CHR(9)||v_indeks||chr(9)||v_nr_anal||
                      chr(9)||v_nr_komp_gr||chr(9)||v_gr_tow||chr(9)||SUBSTR(SQLERRM, 1 , 64) ,v_Date||'kartoteka2.txt');                           
                    
               END;
       END LOOP;  
    CLOSE kursor;
      
      
      
v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.');



--if v_counter<>0 then
--wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter-1 )
--||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2-1)||'  data '||v_date ,v_date||'kartoteka.txt');
--else
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2)||'  data '||v_date ,v_date||'kartoteka2.txt');
--end if;
END KARTOTEKA_PODMIANA2;  
--------------------------------------------------------------------------------------------------------------------------------





















--------------------------------podmiana nr_ins w katalogu----------------------------------------------------------------------
PROCEDURE KATALOG_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20) ;


--v_kartoteka kartoteka%rowtype;
v_katalog katalog%rowtype;

--v_nr_kat kartoteka.nr_kat%TYPE;
v_nr_inst katalog.NR_INST%TYPE;

CURSOR kursor IS SELECT * FROM katalog FOR UPDATE of nr_inst ;

BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') "NOW" INTO v_date FROM DUAL;
IF tryb=1 THEN 
    wpis_do_pliku('UPDATE',v_date||'katalog.txt');
END IF;
wpis_do_pliku('nr_kat'||CHR(9)||'TYP_kat'||CHR(9)||
'nr_inst'||CHR(9)||'nr_inst_new'||chr(9)||'bledy',v_date||'katalog.txt');
    OPEN kursor;  
      LOOP
            FETCH kursor INTO v_katalog;
             EXIT WHEN kursor%NOTFOUND;
              BEGIN
                v_nr_inst := 0;
                v_counter := v_counter + 1;
                v_nr_inst := NR_INST_NEW(v_katalog.nr_KAT);
                --dbms_output.put_line(' kod_old '||v_spisz.kod_str);
   
				IF tryb=1 THEN
        
         --wpis_do_pliku('JESTEM W UPDATE',v_date||'katalog.txt');
         
            IF v_katalog.nr_inst <> v_nr_inst THEN
 
                UPDATE katalog
                             SET  
                                 nr_inst=v_nr_inst
                             WHERE 
                                 CURRENT OF kursor;
             END IF;
                                 
        END IF;

               EXCEPTION
                   WHEN OTHERS THEN
                  
                  v_counter2 := v_counter2 +1;
                  
                 /* IF v_counter2 = 1 THEN
                        wpis_do_pliku('nr_kat'||CHR(9)||'TYP_kat'||CHR(9)||
                        'nr_inst'||CHR(9)||'nr_inst_new'||chr(9)
                        ||'bledy',v_date||'katalog.txt');

                  END IF;*/
                  
                  err_num := SQLCODE;
                  IF err_num=-1 THEN

                    wpis_do_pliku(v_katalog.nr_kat||CHR(9)||v_katalog.TYP_kat||CHR(9)||v_katalog.nr_inst
                      ||CHR(9)||v_nr_inst||'dukplicate indeks' ,v_Date||'katalog.txt');
                  ELSIF err_num=100 THEN
                     wpis_do_pliku(v_katalog.nr_kat||CHR(9)||v_katalog.TYP_kat||CHR(9)||v_katalog.nr_inst
                      ||CHR(9)||chr(9)||'NIE ZNALEZIONO typ_kat W TAB PRZEJSC' ,v_Date||'katalog.txt');
                  ELSE
                      wpis_do_pliku(v_katalog.nr_kat||CHR(9)||v_katalog.TYP_kat||CHR(9)||v_katalog.nr_inst
                      ||CHR(9)||v_nr_inst||SUBSTR(SQLERRM, 1 , 64) ,v_Date||'katalog.txt');
                    
                  END IF;
                                              
                                              
               END;         
       
       END LOOP;
     
    CLOSE kursor;
      
      
      
v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter-1 ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.');



if v_counter<>0 then
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter-1 )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2-1)||'  data '||v_date ,v_date||'katalog.txt');
else
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2)||'  data '||v_date ,v_date||'katalog.txt');
end if;

END KATALOG_PODMIANA;  
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------podmiana spiss dla zrodlo='Z' indeks typ danych zale¿ny od zn_war,kod_dod(kartoteka),nr_kat----------------------------------------------------------------------
PROCEDURE SPISS_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20) ;



v_spiss spiss%rowtype;


v_indeks_new spiss.indeks%TYPE;
v_kod_dod_new spiss.kod_dod%TYPE;
v_nr_kat_new spiss.nr_kat%TYPE;

CURSOR kursor IS SELECT * FROM spiss WHERE zrodlo='Z' /*and nr_komp_zr=482145 and nr_kol=1 and (nr_kat=3603 or nr_kat=3500)*/ FOR UPDATE of indeks,kod_dod,nr_kat ;

BEGIN
  SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') "NOW" INTO v_date FROM DUAL;
IF tryb=1 THEN
        
         wpis_do_pliku('UPDATE',v_date||'spiss.txt');
END IF;

Delete from SPISS WHERE zrodlo='S';

wpis_do_pliku('nr_kat'||CHR(9)||
'kod_dod'||CHR(9)||'indeks'||CHR(9)||'nr_kat_new'||chr(9)||'kod_dod_new'||chr(9)||'indeks_new'||chr(9)||'zn_war'||chr(9)||'bledy'
,v_date||'spiss.txt');
    OPEN kursor;
    
      LOOP
            FETCH kursor INTO v_spiss;
             EXIT WHEN kursor%NOTFOUND;
              BEGIN
                v_counter := v_counter + 1;
                
                V_KOD_DOD_NEW := ' ';
                v_indeks_new := ' ';
                v_nr_kat_new := -1;
                
                IF v_spiss.nr_kat <> 0 THEN
                  v_nr_kat_new := new_nr_kat(v_spiss.nr_kat);
                END if;
                
                --jezeli nie znajdzie to idzie dalej-----------------------
                BEGIN  
                  IF v_spiss.kod_dod <>' ' THEN
                    v_kod_dod_new := NEW_INDEKS_KARTOTEKA(v_spiss.kod_dod);   
                  END IF; 
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                    v_kod_dod_new := v_spiss.kod_dod;
                   WHEN OTHERS THEN
                    wpis_do_pliku(v_spiss.nr_kat||CHR(9)||v_spiss.kod_dod||CHR(9)||
                       v_nr_kat_new||chr(9)||v_kod_dod_new||chr(9)
                       ||SUBSTR(SQLERRM, 1 , 64) ,v_Date||'spiss.txt');
                        
                END;
                -----------------------------------------------------------
                
                IF v_spiss.zn_war='Sur' THEN
                    v_indeks_new := NEW_INDEKS_KATALOG(v_spiss.indeks);    
                ELSIF v_spiss.zn_war='Str' OR v_spiss.zn_war='Pó³' THEN
                    v_indeks_new := new_kod_indeks1(v_spiss.indeks);
                ELSIF v_spiss.zn_war='Obr' THEN
                    IF v_spiss.indeks like '%\%' THEN
                          v_indeks_new := new_kod_indeks1(v_spiss.indeks);
                    ELSE
                          v_indeks_new := NEW_INDEKS_KATALOG(v_spiss.indeks); 
                    END IF;
                END IF;
                /*wpis_do_pliku(v_spiss.nr_kat||CHR(9)||v_spiss.kod_dod||chr(9)||v_spiss.indeks||CHR(9)||
                       v_nr_kat_new||chr(9)||v_kod_dod_new||chr(9)||v_indeks_new||chr(9)||v_spiss.zn_war||chr(9)
                       ||'znaleziono' ,v_Date||'spiss.txt');*/
                --dbms_output.put_line(' kod_old '||v_spisz.kod_str);
 
 
            
				IF tryb=1 THEN
        
         --wpis_do_pliku('JESTEM W UPDATE',v_date||'spiss.txt');
         
           IF v_spiss.nr_kat <> v_nr_kat_new or v_spiss.indeks <> v_indeks_new or v_spiss.kod_dod <> v_kod_dod_new THEN
 
                UPDATE spiss
                             SET  
                                 nr_kat = v_nr_kat_new,
                                 indeks = v_indeks_new,
                                 kod_dod = v_kod_dod_new
                             WHERE 
                                 CURRENT OF kursor;
            END IF;
        END IF;

               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                       v_counter2 := v_counter2 +1;
                       wpis_do_pliku(v_spiss.nr_kat||CHR(9)||v_spiss.kod_dod||chr(9)||v_spiss.indeks||CHR(9)||
                       v_nr_kat_new||chr(9)||v_kod_dod_new||chr(9)||v_indeks_new||chr(9)||v_spiss.zn_war||chr(9)
                       ||'NIE ZNALEZIONO INDEKSU LUB NR_KAT LUB KOD_DOD W TAB PRZEJSC' ,v_Date||'spiss.txt');
                   WHEN DUP_VAL_ON_INDEX THEN
                       v_counter2 := v_counter2 +1;
                       wpis_do_pliku(v_spiss.nr_kat||CHR(9)||v_spiss.kod_dod||chr(9)||v_spiss.indeks||CHR(9)||
                       v_nr_kat_new||chr(9)||v_kod_dod_new||chr(9)||v_indeks_new||chr(9)||v_spiss.zn_war
                       ||chr(9)||'dukplicate indeks' ,v_Date||'spiss.txt');
                   WHEN OTHERS THEN                   
                       v_counter2 := v_counter2 +1;
                       wpis_do_pliku(v_spiss.nr_kat||CHR(9)||v_spiss.kod_dod||chr(9)||v_spiss.indeks||CHR(9)||
                       v_nr_kat_new||chr(9)||v_kod_dod_new||chr(9)||v_indeks_new||chr(9)||v_spiss.zn_war||chr(9)
                       ||SUBSTR(SQLERRM, 1 , 64) ,v_Date||'spiss.txt');
                
               END;         
       END LOOP;     
    CLOSE kursor;
      
      
      
v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter-1 ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.');


--if v_counter<>0 then
--wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter-1 )
--||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2-1)||'  data '||v_date ,v_date||'spiss.txt');
--else
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2)||'  data '||v_date ,v_date||'spiss.txt');
--end if;
END SPISS_PODMIANA;  
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------podmiana w braki_b kod_str na now¹ strukture----------------------------------------------------------------------
PROCEDURE BRAKI_B_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);

v_braki_b braki_b%ROWTYPE;
kod_str_new braki_b.kod_str%TYPE;

cursor kursor IS SELECT * FROM  braki_b FOR UPDATE OF kod_str;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') "NOW" INTO v_date FROM DUAL;
IF tryb=1 THEN
      wpis_do_pliku('UPDATE',v_date||'braki_b.txt');
END IF;
wpis_do_pliku('nr_kol'||chr(9)||'kod_str'||chr(9)||'kod_str_new' ||chr(9)||'bledy',v_date||'braki_b.txt');


OPEN kursor;
    LOOP
        FETCH kursor INTO v_braki_b;
        EXIT WHEN kursor%NOTFOUND;
          BEGIN
            kod_str_new := 0;
            v_counter := v_counter+1;
            kod_str_new := NEW_KOD_INDEKS1(v_braki_b.kod_str);
            
            IF tryb=1 OR tryb=2 THEN
              UPDATE braki_b
              SET kod_str = kod_str_new
              WHERE CURRENT OF kursor;
            END IF;
            
            IF tryb=2 OR tryb=3 THEN
                  wpis_do_pliku(v_braki_b.nr_kol||chr(9)||v_braki_b.kod_str||chr(9)||kod_str_new||chr(9)||
                  'PODMIANA',v_date||'braki_b.txt');
            END IF;
            
            
            EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                  v_counter2 := v_counter2+1;
                  wpis_do_pliku(v_braki_b.nr_kol||chr(9)||v_braki_b.kod_str||chr(9)||kod_str_new||chr(9)||
                  'Nie znaleziono kod_str w tabeli przejsc',v_date||'braki_b.txt');
              WHEN DUP_VAL_ON_INDEX THEN
                   v_counter2 := v_counter2+1;
                   wpis_do_pliku(v_braki_b.nr_kol||chr(9)||v_braki_b.kod_str||chr(9)||kod_str_new||chr(9)||
                  'Duplicate indeks',v_date||'braki_b.txt');
              WHEN OTHERS THEN
                   v_counter2 := v_counter2+1;
                   wpis_do_pliku(v_braki_b.nr_kol||chr(9)||v_braki_b.kod_str||chr(9)||kod_str_new||chr(9)||
                   SUBSTR(SQLERRM, 1 , 64),v_date||'braki_b.txt');
          END;
    END LOOP;
CLOSE kursor;

v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 ))
||' sec. iloœæ bledów: '||v_counter2);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'braki_b.txt');

END BRAKI_B_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------



--------------------------------podmiana w opt_nr nr_kat(struk_trans) i typ_kat z katalogu o nowym numerze----------------------------------------------------------------------
PROCEDURE OPT_NR_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);

v_opt_nr opt_nr%ROWTYPE;
v_nr_kat_new opt_nr.nr_kat%TYPE;
v_typ_kat_new opt_nr.typ_kat%TYPE;

CURSOR kursor IS SELECT * FROM  opt_nr FOR UPDATE OF typ_kat,nr_kat;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') INTO v_date FROM DUAL;
IF tryb=1 THEN
  wpis_do_pliku('UPDATE',v_date||'opt_nr.txt');
END IF;
wpis_do_pliku('nr_opt'||chr(9)||'typ_kat'||chr(9)||'nr_kat'||chr(9)||'typ_new'||chr(9)||'nr_new'
||chr(9)||'blad',v_date||'opt_nr.txt');

OPEN kursor;
  LOOP
    FETCH kursor INTO v_opt_nr;
    EXIT WHEN kursor%NOTFOUND;
      BEGIN
        v_nr_kat_new := 0;
        v_typ_kat_new := ' ';
        v_counter := v_counter+1;
        v_nr_kat_new := NEW_NR_KAT(v_opt_nr.nr_kat);
        
        IF v_nr_kat_new<>0 THEN
          SELECT TYP_KAT INTO v_typ_kat_new
          FROM katalog
          WHERE nr_kat = v_nr_kat_new;
        END IF;
      
        
            -- wpis_do_pliku(v_opt_nr.nr_opt||chr(9)||v_opt_nr.typ_kat||chr(9)||v_opt_nr.nr_kat||CHr(9)
            --||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'update',v_date||'opt_nr.txt');
              
      
        IF tryb=1 THEN 
          UPDATE opt_nr
          SET nr_kat = v_nr_kat_new,
              typ_kat = v_typ_kat_new
          WHERE CURRENT OF kursor;  
        END IF;
        
           
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_opt_nr.nr_opt||chr(9)||v_opt_nr.typ_kat||chr(9)||v_opt_nr.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'nie znaleziono nr_kat w tabeli przejsc lub typ_kat w katalogu o nowym nr_kat',v_date||'opt_nr.txt');
          WHEN DUP_VAL_ON_INDEX THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_opt_nr.nr_opt||chr(9)||v_opt_nr.typ_kat||chr(9)||v_opt_nr.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'DUPLICATE INDEKS',v_date||'opt_nr.txt');
          WHEN OTHERS THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_opt_nr.nr_opt||chr(9)||v_opt_nr.typ_kat||chr(9)||v_opt_nr.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||SUBSTR(SQLERRM, 1 , 64),v_date||'opt_nr.txt');
      END;
  END LOOP;
CLOSE kursor; 



v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 ))
||' sec. iloœæ bledów: '||v_counter2);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'opt_nr.txt');

END OPT_NR_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------



--------------------------------podmiana w opt_taf nr_kat(struk_trans) i typ_kat z katalogu o nowym numerze----------------------------------------------------------------------
PROCEDURE OPT_TAF_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);

v_opt_taf opt_taf%ROWTYPE;
v_nr_kat_new opt_taf.nr_kat%TYPE;
v_typ_kat_new opt_taf.typ_kat%TYPE;

CURSOR kursor IS SELECT * FROM  opt_taf FOR UPDATE OF typ_kat,nr_kat;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') INTO v_date FROM DUAL;
IF tryb=1 THEN
  wpis_do_pliku('UPDATE',v_date||'opt_taf.txt');
END IF;
wpis_do_pliku('nr_opt'||chr(9)||'typ_kat'||chr(9)||'nr_kat'||chr(9)||'typ_new'||chr(9)||'nr_new'
||chr(9)||'blad',v_date||'opt_taf.txt');

OPEN kursor;
  LOOP
    FETCH kursor INTO v_opt_taf;
    EXIT WHEN kursor%NOTFOUND;
      BEGIN
        v_nr_kat_new := 0;
        v_typ_kat_new := ' ';
        v_counter := v_counter+1;
        v_nr_kat_new := NEW_NR_KAT(v_opt_taf.nr_kat);
        
        IF v_nr_kat_new<>0 THEN
          SELECT TYP_KAT INTO v_typ_kat_new
          FROM katalog
          WHERE nr_kat = v_nr_kat_new;
        END IF;
      
        
            -- wpis_do_pliku(v_opt_nr.nr_opt||chr(9)||v_opt_nr.typ_kat||chr(9)||v_opt_nr.nr_kat||CHr(9)
            --||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'update',v_date||'opt_nr.txt');
              
      
        IF tryb=1 THEN 
          UPDATE opt_taf
          SET nr_kat = v_nr_kat_new,
              typ_kat = v_typ_kat_new
          WHERE CURRENT OF kursor;  
        END IF;
        
           
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_opt_taf.nr_opt||chr(9)||v_opt_taf.typ_kat||chr(9)||v_opt_taf.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'nie znaleziono nr_kat w tabeli przejsc lub typ_kat w katalogu o nowym nr_kat',v_date||'opt_taf.txt');
          WHEN DUP_VAL_ON_INDEX THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_opt_taf.nr_opt||chr(9)||v_opt_taf.typ_kat||chr(9)||v_opt_taf.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'DUPLICATE INDEKS',v_date||'opt_taf.txt');
          WHEN OTHERS THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_opt_taf.nr_opt||chr(9)||v_opt_taf.typ_kat||chr(9)||v_opt_taf.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||SUBSTR(SQLERRM, 1 , 64),v_date||'opt_taf.txt');
      END;
  END LOOP;
CLOSE kursor; 



v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 ))
||' sec. iloœæ bledów: '||v_counter2);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'opt_taf.txt');

END OPT_TAF_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------



--------------------------------podmiana w paml303nr_kat(struk_trans) i typ_kat z katalogu o nowym numerze----------------------------------------------------------------------
PROCEDURE paml303_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);

v_paml303 paml303%ROWTYPE;
v_nr_kat_new paml303.nr_kat%TYPE;
v_typ_kat_new paml303.typ_kat%TYPE;

CURSOR kursor IS SELECT * FROM  paml303 FOR UPDATE OF typ_kat,nr_kat;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') INTO v_date FROM DUAL;
IF tryb=1 THEN
  wpis_do_pliku('UPDATE',v_date||'paml303.txt');
END IF;
wpis_do_pliku('nr_komp_zlec'||chr(9)||'typ_kat'||chr(9)||'nr_kat'||chr(9)||'typ_new'||chr(9)||'nr_new'
||chr(9)||'blad',v_date||'paml303.txt');

OPEN kursor;
  LOOP
    FETCH kursor INTO v_paml303;
    EXIT WHEN kursor%NOTFOUND;
      BEGIN
        v_nr_kat_new := 0;
        v_typ_kat_new := ' ';
        v_counter := v_counter+1;
        v_nr_kat_new := NEW_NR_KAT(v_paml303.nr_kat);
        
        IF v_nr_kat_new<>0 THEN
          SELECT TYP_KAT INTO v_typ_kat_new
          FROM katalog
          WHERE nr_kat = v_nr_kat_new;
        END IF;
      
        
            -- wpis_do_pliku(v_opt_nr.nr_kom_zlec||chr(9)||v_opt_nr.typ_kat||chr(9)||v_opt_nr.nr_kat||CHr(9)
            --||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'update',v_date||'opt_nr.txt');
              
      
        IF tryb=1 THEN 
          UPDATE paml303
          SET nr_kat = v_nr_kat_new,
              typ_kat = v_typ_kat_new
          WHERE CURRENT OF kursor;  
        END IF;
        
           
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_paml303.nr_komp_zlec||chr(9)||v_paml303.typ_kat||chr(9)||v_paml303.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'nie znaleziono nr_kat w tabeli przejsc lub typ_kat w katalogu o nowym nr_kat',v_date||'paml303.txt');
          WHEN DUP_VAL_ON_INDEX THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_paml303.nr_komp_zlec||chr(9)||v_paml303.typ_kat||chr(9)||v_paml303.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'DUPLICATE INDEKS',v_date||'paml303.txt');
          WHEN OTHERS THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_paml303.nr_komp_zlec||chr(9)||v_paml303.typ_kat||chr(9)||v_paml303.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||SUBSTR(SQLERRM, 1 , 64),v_date||'paml303.txt');
      END;
  END LOOP;
CLOSE kursor; 



v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 ))
||' sec. iloœæ bledów: '||v_counter2);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'paml303.txt');

END paml303_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------podmiana w paml66nr_kat(struk_trans) i typ_kat z katalogu o nowym numerze----------------------------------------------------------------------
PROCEDURE paml66_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);

v_paml66 paml66%ROWTYPE;
v_nr_kat_new paml66.nr_kat%TYPE;
v_typ_kat_new paml66.typ_kat%TYPE;
v_naz_kat_new paml66.naz_kat%TYPE;

CURSOR kursor IS SELECT * FROM  paml66 FOR UPDATE OF typ_kat,nr_kat,naz_kat;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') INTO v_date FROM DUAL;
IF tryb=1 THEN
  wpis_do_pliku('UPDATE',v_date||'paml66.txt');
END IF;
wpis_do_pliku('nr_listy'||chr(9)||'typ_kat'||chr(9)||'nr_kat'||chr(9)||'typ_new'||chr(9)||'nr_new'
||chr(9)||'blad',v_date||'paml66.txt');

OPEN kursor;
  LOOP
    FETCH kursor INTO v_paml66;
    EXIT WHEN kursor%NOTFOUND;
      BEGIN
        v_nr_kat_new := 0;
        v_typ_kat_new := ' ';
        v_counter := v_counter+1;
        v_nr_kat_new := NEW_NR_KAT(v_paml66.nr_kat);
        
        IF v_nr_kat_new<>0 THEN
          SELECT TYP_KAT,naz_kat INTO v_typ_kat_new,v_naz_kat_new
          FROM katalog
          WHERE nr_kat = v_nr_kat_new;
        END IF;
      
        
            -- wpis_do_pliku(v_opt_nr.nr_kom_zlec||chr(9)||v_opt_nr.typ_kat||chr(9)||v_opt_nr.nr_kat||CHr(9)
            --||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'update',v_date||'opt_nr.txt');
              
      
        IF tryb=1 THEN 
          UPDATE paml66
          SET nr_kat = v_nr_kat_new,
              typ_kat = v_typ_kat_new,
              naz_kat = v_naz_kat_new
          WHERE CURRENT OF kursor;  
        END IF;
        
           
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_paml66.nr_listy||chr(9)||v_paml66.typ_kat||chr(9)||v_paml66.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'nie znaleziono nr_kat w tabeli przejsc lub typ_kat w katalogu o nowym nr_kat',v_date||'paml66.txt');
          WHEN DUP_VAL_ON_INDEX THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_paml66.nr_listy||chr(9)||v_paml66.typ_kat||chr(9)||v_paml66.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||'DUPLICATE INDEKS',v_date||'paml66.txt');
          WHEN OTHERS THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_paml66.nr_listy||chr(9)||v_paml66.typ_kat||chr(9)||v_paml66.nr_kat||CHr(9)
             ||v_typ_kat_new||chr(9)||v_nr_kat_new||chr(9)||SUBSTR(SQLERRM, 1 , 64),v_date||'paml66.txt');
      END;
  END LOOP;
CLOSE kursor; 



v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 ))
||' sec. iloœæ bledów: '||v_counter2);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'paml66.txt');

END paml66_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------



--------------------------------podmiana w str_w_zlec struktur----------------------------------------------------------------------
PROCEDURE str_w_zlec_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);

v_str_w_zlec str_w_zlec%ROWTYPE;
v_kod_new str_w_zlec.nr_kom_str%TYPE;


CURSOR kursor IS SELECT * FROM  str_w_zlec FOR UPDATE OF nr_kom_str;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') INTO v_date FROM DUAL;
IF tryb=1 THEN
  wpis_do_pliku('UPDATE',v_date||'str_w_zlec.txt');
END IF;
wpis_do_pliku('nr_kom_zlec'||chr(9)||'nr_kom_str'||chr(9)||'kod_new'||chr(9)||'blad',v_date||'str_w_zlec.txt');

OPEN kursor;
  LOOP
    FETCH kursor INTO v_str_w_zlec;
    EXIT WHEN kursor%NOTFOUND;
      BEGIN
        v_kod_new := ' ';
        v_counter := v_counter+1;
        v_kod_new := NEW_KOD_INDEKS1(V_str_w_zlec.nr_kom_str);
        
       
      
        IF tryb=1 THEN 
          UPDATE str_w_zlec
          SET nr_kom_str = v_kod_new
          WHERE CURRENT OF kursor;  
        END IF;
        
           
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_str_w_zlec.nr_kom_zlec||chr(9)||v_str_w_zlec.nr_kom_str||chr(9)||v_kod_new||CHr(9)
             ||'nie znaleziono nr_kat w tabeli przejsc lub typ_kat w katalogu o nowym nr_kat',v_date||'str_w_zlec.txt');
          WHEN DUP_VAL_ON_INDEX THEN
             v_counter2 := v_counter2+1;
              wpis_do_pliku(v_str_w_zlec.nr_kom_zlec||chr(9)||v_str_w_zlec.nr_kom_str||chr(9)||v_kod_new||CHr(9)
             ||'duplikate indeks',v_date||'str_w_zlec.txt');
          WHEN OTHERS THEN
             v_counter2 := v_counter2+1;
              wpis_do_pliku(v_str_w_zlec.nr_kom_zlec||chr(9)||v_str_w_zlec.nr_kom_str||chr(9)||v_kod_new||CHr(9)
             ||SUBSTR(SQLERRM, 1 , 64),v_date||'str_w_zlec.txt');
      END;
  END LOOP;
CLOSE kursor; 



v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' 
||TO_CHAR (ROUND ( v_end_time/100,2 ))||' sec. iloœæ bledów: '||v_counter2);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'str_w_zlec.txt');

END str_w_zlec_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------




--podmiana w wykzal 
/*
1. Sprawdza czy indeks jest w kartotece.
2. Jeœli tak, to zamienia tylko nr_kat.
3. Jeœli nie, to sprawdzamy czy indeks ma w sobie '\', jak ma to traktujemy go jako indeks struktury i jest szukany w tabeli przejœæ (typ=3) a nr_kat zeruje.
4. Jeœli nie ma '\' i nie znalaz³o w kartotece, to szuka indeksu w tabeli przejœæ z typem 1, czyli katalog i podmienia te¿ nr_kat.
Do³o¿y³em warunek ¿e jeœli indeks jest pusty to podmieniam tylko nr_kat i nie ma wpisu w logu.
*/
PROCEDURE WYKZAL_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);
v_check number;
ile PLS_INTEGER := 0;--liczba wszytskioch iteracji

v_wykzal wykzal%ROWTYPE;
v_nr_kat_new wykzal.nr_kat%TYPE;
v_indeks_new wykzal.indeks%TYPE;


CURSOR kursor IS SELECT * FROM  wykzal FOR UPDATE OF indeks,nr_kat;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') INTO v_date FROM DUAL;
IF tryb=1 THEN
  wpis_do_pliku('UPDATE',v_date||'wykzal.txt');
END IF;
wpis_do_pliku('nr_komp_zlec'||chr(9)||'indeks'||chr(9)||'nr_kat'||chr(9)||'indeks_new'||chr(9)||'nr_new'
||chr(9)||'blad',v_date||'wykzal.txt');

OPEN kursor;
  LOOP
    FETCH kursor INTO v_wykzal;
    EXIT WHEN kursor%NOTFOUND;

      BEGIN
        v_nr_kat_new := 0;
        v_counter := v_counter+1;
        v_indeks_new := ' ';
        v_check := 0;

        
        
        IF v_wykzal.indeks <> ' ' || (TRIM(v_wykzal.indeks)) THEN
        
        
                   
               




                SELECT nvl(max(nr_kat),-1) INTO v_check 
                FROM kartoteka
                WHERE indeks = v_wykzal.indeks;
                            
                            
                            
                    IF v_wykzal.indeks like '%\%' AND v_check = -1 THEN
                    ------------
                    
                    
                    v_indeks_new := NEW_KOD_INDEKS1(v_wykzal.indeks);
                    v_nr_kat_new := 0;
                             
                             IF tryb=1 THEN 
                                  UPDATE wykzal
                                  SET nr_kat = v_nr_kat_new,
                                      indeks = v_indeks_new
                                  WHERE CURRENT OF kursor;   
                             END IF;
                          
                          
                          
                         
                            
                   ELSE
                   
                              IF v_check=-1  THEN


                              v_indeks_new := NEW_INDEKS_KATALOG(v_wykzal.indeks);
                              v_nr_kat_new := NEW_NR_KAT(v_wykzal.nr_kat);
                              
                                IF tryb=1 THEN 
                                  UPDATE wykzal
                                  SET nr_kat = v_nr_kat_new,
                                      indeks = v_indeks_new
                                  WHERE CURRENT OF kursor;  
                                 END IF;
                            ELSIF tryb=1 AND v_check<>-1 THEN
                             ile := ile+1;
                                v_nr_kat_new := v_check;
                                  IF tryb=1 THEN 
                                    UPDATE wykzal
                                    SET nr_kat = v_nr_kat_new
                                    WHERE CURRENT OF kursor;  
                                  END IF;
                            END IF;
                   
                   END IF;
                    
          ELSE
          
                       
                        v_nr_kat_new := NEW_NR_KAT(v_wykzal.nr_kat);
                        
                        IF tryb=1 THEN          
                            --stare
                            --nowe
                                

                                    UPDATE wykzal
                                    SET nr_kat = v_nr_kat_new
                                    WHERE CURRENT OF kursor;  
                            --nowe
                        END IF;
                    
          END IF;
        
        
       /* IF tryb=1 THEN 
              wpis_do_pliku(v_wykzal.nr_komp_zlec||chr(9)||v_wykzal.indeks||chr(9)||v_wykzal.nr_kat||CHr(9)
             ||v_indeks_new||chr(9)||v_nr_kat_new||chr(9)||'update',v_date||'wykzal.txt');
        end if;*/
   
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_wykzal.nr_komp_zlec||chr(9)||v_wykzal.indeks||chr(9)||v_wykzal.nr_kat||CHr(9)
             ||v_indeks_new||chr(9)||v_nr_kat_new||chr(9)||'nie znaleziono nr_kat lub indeksu w tabeli przejsc',v_date||'wykzal.txt');
          WHEN DUP_VAL_ON_INDEX THEN
             v_counter2 := v_counter2+1;
              wpis_do_pliku(v_wykzal.nr_komp_zlec||chr(9)||v_wykzal.indeks||chr(9)||v_wykzal.nr_kat||CHr(9)
             ||v_indeks_new||chr(9)||v_nr_kat_new||chr(9)||'duplicate index',v_date||'wykzal.txt');
          
          WHEN OTHERS THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_wykzal.nr_komp_zlec||chr(9)||v_wykzal.indeks||chr(9)||v_wykzal.nr_kat||CHr(9)
             ||v_indeks_new||chr(9)||v_nr_kat_new||chr(9)||SUBSTR(SQLERRM, 1 , 64),v_date||'wykzal.txt');
          
      END;
  END LOOP;
CLOSE kursor; 



v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 ))
||' sec. iloœæ bledów: '||v_counter2||' ile:'||ile);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'wykzal.txt');

END WYKZAL_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------podmiana w cr_data typu ktalogowego----------------------------------------------------------------------
PROCEDURE CR_DATA_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);

v_cr_data cr_data%ROWTYPE;
v_kod_new cr_data.typ_kat%TYPE;


CURSOR kursor IS SELECT * FROM  cr_data FOR UPDATE OF typ_kat;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') INTO v_date FROM DUAL;
IF tryb=1 THEN
  wpis_do_pliku('UPDATE',v_date||'cr_data.txt');
END IF;
wpis_do_pliku('lp'||chr(9)||'typ_kat'||chr(9)||'kod_new'||chr(9)||'blad',v_date||'cr_data.txt');

OPEN kursor;
  LOOP
    FETCH kursor INTO v_cr_data;
    EXIT WHEN kursor%NOTFOUND;
      BEGIN
        v_kod_new := ' ';
        v_counter := v_counter+1;
        v_kod_new := NEW_INDEKS_KATALOG(V_cr_data.typ_kat);
        
       
      
        IF tryb=1 THEN 
          UPDATE cr_data
          SET typ_kat = v_kod_new
          WHERE CURRENT OF kursor;  
        END IF;
        
           
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_cr_data.lp||chr(9)||v_cr_data.typ_kat||chr(9)||v_kod_new||CHr(9)
             ||'nie znaleziono typ_kat w tabeli przejsc',v_date||'cr_data.txt');
          WHEN DUP_VAL_ON_INDEX THEN
             v_counter2 := v_counter2+1;
              v_counter2 := v_counter2+1;
             wpis_do_pliku(v_cr_data.lp||chr(9)||v_cr_data.typ_kat||chr(9)||v_kod_new||CHr(9)
             ||'duplikate indeks',v_date||'cr_data.txt');
          WHEN OTHERS THEN
             v_counter2 := v_counter2+1;
              v_counter2 := v_counter2+1;
             wpis_do_pliku(v_cr_data.lp||chr(9)||v_cr_data.typ_kat||chr(9)||v_kod_new||CHr(9)
             ||SUBSTR(SQLERRM, 1 , 64),v_date||'cr_data.txt');
      END;
  END LOOP;
CLOSE kursor; 



v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' 
||TO_CHAR (ROUND ( v_end_time/100,2 ))||' sec. iloœæ bledów: '||v_counter2);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'cr_data.txt');

END CR_DATA_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------podmiana w cr_results typu ktalogowego----------------------------------------------------------------------
PROCEDURE CR_RESULTS_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);

v_cr_results cr_results%ROWTYPE;
v_kod_new cr_results.typ_kat%TYPE;


CURSOR kursor IS SELECT * FROM  cr_results FOR UPDATE OF typ_kat;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') INTO v_date FROM DUAL;
IF tryb=1 THEN
  wpis_do_pliku('UPDATE',v_date||'cr_results.txt');
END IF;
wpis_do_pliku('ID_CR'||chr(9)||'typ_kat'||chr(9)||'kod_new'||chr(9)||'blad',v_date||'cr_results.txt');

OPEN kursor;
  LOOP
    FETCH kursor INTO v_cr_results;
    EXIT WHEN kursor%NOTFOUND;
      BEGIN
        v_kod_new := ' ';
        v_counter := v_counter+1;
        v_kod_new := NEW_INDEKS_KATALOG(V_cr_results.typ_kat);
        
       
      
        IF tryb=1 THEN 
          UPDATE cr_results
          SET typ_kat = v_kod_new
          WHERE CURRENT OF kursor;  
        END IF;
        
           
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_counter2 := v_counter2+1;
             wpis_do_pliku(v_cr_results.ID_CR||chr(9)||v_cr_results.typ_kat||chr(9)||v_kod_new||CHr(9)
             ||'nie znaleziono typ_kat w tabeli przejsc',v_date||'cr_results.txt');
          WHEN DUP_VAL_ON_INDEX THEN
             v_counter2 := v_counter2+1;
              v_counter2 := v_counter2+1;
             wpis_do_pliku(v_cr_results.ID_CR||chr(9)||v_cr_results.typ_kat||chr(9)||v_kod_new||CHr(9)
             ||'duplikate indeks',v_date||'cr_results.txt');
          WHEN OTHERS THEN
             v_counter2 := v_counter2+1;
              v_counter2 := v_counter2+1;
             wpis_do_pliku(v_cr_results.ID_CR||chr(9)||v_cr_results.typ_kat||chr(9)||v_kod_new||CHr(9)
             ||SUBSTR(SQLERRM, 1 , 64),v_date||'cr_results.txt');
      END;
  END LOOP;
CLOSE kursor; 


v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' 
||TO_CHAR (ROUND ( v_end_time/100,2 ))||' sec. iloœæ bledów: '||v_counter2);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'cr_results.txt');

END CR_RESULTS_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------



--------------------------------podmiana w l_wyc typu katalogowego lub indeks str----------------------------------------------------------------------
PROCEDURE L_WYC_PODMIANA(tryb IN NUMBER)
IS
err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20);

v_l_wyc l_wyc%ROWTYPE;
v_kod_new l_wyc.typ_kat%TYPE;



CURSOR kursor IS SELECT * FROM  l_wyc FOR UPDATE OF typ_kat;
BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') INTO v_date FROM DUAL;
IF tryb=1 THEN
  wpis_do_pliku('UPDATE',v_date||'l_wyc.txt');
END IF;
wpis_do_pliku('nr_kom_zlec'||chr(9)||'typ_kat'||chr(9)||'kod_new'||chr(9)||'blad',v_date||'l_wyc.txt');

OPEN kursor;
  LOOP
    FETCH kursor INTO v_l_wyc;
    EXIT WHEN kursor%NOTFOUND;
      BEGIN
        v_kod_new := ' ';
        v_counter := v_counter+1;
        
        IF v_l_wyc.rodz_sur <> 'Pó³' THEN
          v_kod_new := NEW_INDEKS_KATALOG(V_l_wyc.typ_kat);
        ELSIF v_l_wyc.rodz_sur = 'Pó³' THEN
          v_kod_new := NEW_KOD_INDEKS1(V_l_wyc.typ_kat);
        END IF;
      
        IF tryb=1 THEN 
          UPDATE l_wyc
          SET typ_kat = v_kod_new
          WHERE CURRENT OF kursor;  
        END IF;
        
           
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_counter2 := v_counter2+1;
             IF v_l_wyc.rodz_sur <> 'Pó³'THEN
              wpis_do_pliku(v_l_wyc.nr_kom_zlec||chr(9)||v_l_wyc.typ_kat||chr(9)||v_kod_new||CHr(9)
              ||'nie znaleziono typ_kat w tabeli przejsc(KATALOG)',v_date||'l_wyc.txt');
             ELSIF v_l_wyc.rodz_sur = 'Pó³'THEN
              wpis_do_pliku(v_l_wyc.nr_kom_zlec||chr(9)||v_l_wyc.typ_kat||chr(9)||v_kod_new||CHr(9)
              ||'nie znaleziono typ_kat w tabeli przejsc(STRUKTURA)',v_date||'l_wyc.txt');
             END IF;
          WHEN DUP_VAL_ON_INDEX THEN
             v_counter2 := v_counter2+1;
              v_counter2 := v_counter2+1;
             wpis_do_pliku(v_l_wyc.nr_kom_zlec||chr(9)||v_l_wyc.typ_kat||chr(9)||v_kod_new||CHr(9)
             ||'duplikate indeks',v_date||'l_wyc.txt');
          WHEN OTHERS THEN
             v_counter2 := v_counter2+1;
              v_counter2 := v_counter2+1;
             wpis_do_pliku(v_l_wyc.nr_kom_zlec||chr(9)||v_l_wyc.typ_kat||chr(9)||v_kod_new||CHr(9)
             ||SUBSTR(SQLERRM, 1 , 64),v_date||'l_wyc.txt');
      END;
  END LOOP;
CLOSE kursor; 


v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' 
||TO_CHAR (ROUND ( v_end_time/100,2 ))||' sec. iloœæ bledów: '||v_counter2);

wpis_do_pliku('Przetworzono ' || TO_CHAR (v_counter ) ||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||
' sec. iloœæ bledów: '||v_counter2,v_date||'l_wyc.txt');

END L_WYC_PODMIANA;
--------------------------------------------------------------------------------------------------------------------------------


----------------zamiana nr_inst i typ_inst1 w Kartotece----------------------------------------------------------------------------------------
--na razie nie--je¿eli nie ma w tab przejsc, je¿eli typ_kat jest ten sam w starym katalogu to zostawiamy tak samo--------------------------------------------
procedure KATALOG_INST_PODMIANA
IS
BEGIN

--zerowanie nr_inst katalogu nowego--
UPDATE KATALOG
SET NR_INST = 0,
    TYP_INST1 = ' ';



UPDATE katalog Kn
SET (typ_inst1, nr_inst) =
    (select Ko.typ_inst1, Ko.nr_inst
     from katalog@LNK_ORG Ko, struk_trans T
     where T.nr_new=Kn.nr_kat and Ko.nr_kat=T.nr_old and T.typ=1 and nr_odd=(select nr_odz from firma)
           and rownum=1 )
WHERE   --nr_kat=55 AND
   EXISTS (select 1 from katalog@LNK_ORG Ko, struk_trans T
              where T.nr_new=Kn.nr_kat and Ko.nr_kat=T.nr_old and T.typ=1 and nr_odd=(select nr_odz from firma));




/*err_num NUMBER;
v_start_time PLS_INTEGER := DBMS_UTILITY.GET_TIME;--tes czasu wykonania
v_end_time   PLS_INTEGER;--tes czasu wykonania
v_counter    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_counter2    PLS_INTEGER := 0;--liczba wszytskioch iteracji
v_date        varchar2(20) ;

v_katalog katalog%ROWTYPE;
v_nr_kat_old katalog.nr_kat%TYPE;
v_nr_ins_old katalog.nr_inst%TYPE;
v_typ_ins_old katalog.typ_inst1%TYPE;
--v_nr_ins_new katalog.nr_inst%TYPE;
--v_typ_ins_new katalog.typ_inst1%TYPE;


v_blad number(2);
CURSOR kursor IS SELECT * FROM katalog ;

BEGIN

SELECT TO_CHAR(SYSDATE, 'MM-DD HH24.MI') "NOW" INTO v_date FROM DUAL;
IF tryb=1 THEN
    wpis_do_pliku('UPDATE',v_date||'katalog_inst.txt');
END IF;
wpis_do_pliku( 'nr_kat'||CHR(9)||'typ_kat'||CHR(9)||
                        'nr_kat_old'||CHR(9)||'bledy',v_date||'katalog_inst.txt');



  OPEN kursor;
    
      LOOP
      
          FETCH kursor INTO  v_katalog ;
          EXIT WHEN kursor%NOTFOUND; 
            BEGIN
                
                v_nr_kat_old := 0;
                v_nr_ins_old := 0;
                v_typ_ins_old := '';
                v_nr_kat_old := OLD_NR_KAT(v_katalog.nr_kat);
				


            

             
            
            EXCEPTION
                  WHEN OTHERS THEN
                  v_counter2 := v_counter2 + 1;
                  err_num := SQLCODE;
                  if err_num=-1 then
        
                      wpis_do_pliku(v_katalog.nr_kat||CHR(9)||v_katalog.typ_kat||CHR(9)
                      ||CHR(9)||v_nr_kat_old||CHR(9)||'dukplicate indeks' ,v_Date||'katalog_inst.txt');
                  
                  ELSIF err_num=100 THEN
                       wpis_do_pliku(v_katalog.nr_kat||CHR(9)||v_katalog.typ_kat||CHR(9)
                      ||CHR(9)||v_nr_kat_old||CHR(9)||'nie znaleziono nr_kat w tab przejœæ' ,v_date||'katalog_inst.txt');
                      
                  ELSE    
                      wpis_do_pliku(v_katalog.nr_kat||CHR(9)||v_katalog.typ_kat||CHR(9)
                      ||CHR(9)||v_nr_kat_old||CHR(9)||SUBSTR(SQLERRM, 1 , 64) ,v_Date||'katalog_inst.txt');
                  END IF;

            END;
            
     
            v_counter := v_counter + 1;
      END LOOP;
  CLOSE  kursor;
    
    
v_end_time := DBMS_UTILITY.GET_TIME - v_start_time;
DBMS_OUTPUT.PUT_LINE ('Przetworzono ' || TO_CHAR (v_counter )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||to_char(v_counter2-1)||'  data '||v_date );


if v_counter<>0 then
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter-1 )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2-1)||'  data '||v_date ,v_date||'katalog_inst.txt');
else
wpis_do_pliku(CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||CHR(9)||'Przetworzono ' || TO_CHAR (v_counter )
||' rekordow  w czasie ' ||TO_CHAR (ROUND ( v_end_time/100,2 )) ||' sec.  iloœæ bêdów '||TO_CHAR(v_counter2)||'  data '||v_date ,v_date||'katalog_inst.txt');
end if;*/


END KATALOG_INST_PODMIANA;
------------------------------------------------------------------------------------------------------------------------------------




END PKG_STRUK_TRANS;

--SHOW ERROR                                                                                                            
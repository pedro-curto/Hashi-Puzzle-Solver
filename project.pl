% ------------------------------------------------------------------------------------------------%
% -----------------------------|          Pedro Curto          |----------------------------------%
% -----------------------------|           ist1103091          |----------------------------------%
% -----------------------------| Solucionador de Puzzles Hashi |----------------------------------%
% ------------------------------------------------------------------------------------------------%


% --------------------------------- 2.1. extrai_ilhas_linha/2 -----------------------------------%
/*                                                                                                                                               
O predicado extrai_ilhas_linha(N_l, Linha, Ilhas) eh definido do seguinte modo: o primeiro elemento, 
N_L, eh um inteiro positivo que representa o numero de uma linha; o segundo, Linha, eh uma lista que 
corresponde a uma linha de um puzzle; e o terceiro, Ilhas, eh a lista ordenada que contem as ilhas 
da linha dada.                                                                                                               
*/                                                                                                                                    
extrai_ilhas_linha(N_L, Linha, Ilhas) :-
    findall(ilha(X, (N_L, Coluna)), (nth1(Coluna, Linha, X), X > 0), Ilhas).


% ---------------------------------------- 2.2. ilhas/2 ------------------------------------------%
/*
O predicado ilhas(Puz, Ilhas) eh constituido por Puz, um puzzle, e Ilhas, uma lista ordenada 
(ordem: esquerda para a direita, cima para baixo) constituida pelas ilhas de Puz, sendo a estrutura 
de cada uma do tipo: ilha(N,(L,C)), onde N eh o numero de pontes da ilha, e L,C a linha e coluna 
que a ilha ocupa, respetivamente, formando assim a sua posicao.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
*/
ilhas(Puz, Ilhas) :- ilhas(Puz, Ilhas, 0, []).
ilhas([], Aux, _, Aux).
ilhas([P|R], Ilhas, NL, Aux) :-
    New_NL is NL + 1,
    extrai_ilhas_linha(New_NL, P, Ilhas_Puz),
    append(Aux, Ilhas_Puz, Nova_Aux),
    ilhas(R, Ilhas, New_NL, Nova_Aux).


% --------------------------------------- 2.3. vizinhas/3 ----------------------------------------%
/*
O predicado vizinhas(Ilhas, Ilha, Vizinhas) eh constituido por Ilhas, uma lista que contem ilhas de 
um puzzle, Ilha, uma dessas ilhas, e Vizinhas, uma lista ordenada constituida pelas ilhas vizinhas 
de Ilha.
*/
% Funcao auxiliar: retira o primeiro elemento de uma lista
first_aux([],[]) :- !.
first_aux(Lst, Primeiro) :-
    length(Lst, Len),
    Len > 0,
    Lst = [P|_],
    Primeiro = [P].

% Funcao auxiliar: retira o ultimo elemento de uma lista
last_aux([], []) :- !.
last_aux(Lst, Ultimo) :- length(Lst, Len), Len > 0, last(Lst, Last), Ultimo = [Last].

/* Raciocinio: separar em duas listas, uma contendo todas as ilhas na mesma coluna da ilha dada, e 
outra contendo todas as ilhas na mesma linha da ilha dada; depois, separar a lista de ilhas na mesma 
coluna, nas ilhas acima e abaixo, e a lista de ilhas na mesma linha, em ilhas a esquerda e a 
direita; escolhe-se o primeiro elemento das ilhas a direita e abaixo, e o ultimo elemento das ilhas 
a esquerda e acima, e une-se por ordem */
vizinhas(Ilhas, ilha(_,(Linha,Coluna)), Vizinhas) :-
    findall(ilha(N2,(Linha2,Coluna2)), (member(ilha(N2,(Linha2,Coluna2)), Ilhas), Linha2 =:= Linha,
    Coluna2 =\= Coluna), Mesma_Linha),
    % Ilhas na mesma linha a esquerda
    findall(ilha(N2,(Linha2,Coluna2)), (member(ilha(N2,(Linha2,Coluna2)), Mesma_Linha), 
    Coluna - Coluna2 > 0), Mesma_Linha_Esquerda),
    last_aux(Mesma_Linha_Esquerda, Vizinhas_Esquerda), 
    % Ilhas na mesma linha a direita
    findall(ilha(N2,(Linha2,Coluna2)), (member(ilha(N2,(Linha2,Coluna2)), Mesma_Linha), 
    Coluna - Coluna2 < 0), Mesma_Linha_Direita),
    first_aux(Mesma_Linha_Direita, Vizinhas_Direita),
    findall(ilha(N2,(Linha2,Coluna2)), (member(ilha(N2,(Linha2,Coluna2)), Ilhas), 
    Coluna2 =:= Coluna, Linha2 =\= Linha), Mesma_Coluna),
    % Ilhas na mesma coluna e acima
    findall(ilha(N2,(Linha2,Coluna2)), (member(ilha(N2,(Linha2,Coluna2)), Mesma_Coluna), 
    Linha - Linha2 > 0), Mesma_Coluna_Cima),
    last_aux(Mesma_Coluna_Cima, Vizinhas_Cima),
    % Ilhas na mesma coluna e abaixo
    findall(ilha(N2,(Linha2,Coluna2)), (member(ilha(N2,(Linha2,Coluna2)), Mesma_Coluna), 
    Linha - Linha2 < 0), Mesma_Coluna_Baixo),
    first_aux(Mesma_Coluna_Baixo, Vizinhas_Baixo),
    append([Vizinhas_Cima, Vizinhas_Esquerda, Vizinhas_Direita, Vizinhas_Baixo], Vizinhas).


% ---------------------------------------- 2.4. estado/2 -----------------------------------------%
/* 
O predicado estado(Ilhas, Estado) eh constituido por Ilhas, a lista de ilhas de um puzzle, e Estado, 
sendo este uma lista ordenada constituida por entradas relativas a cada uma das ilhas da lista 
Ilhas. Um estado tem a seguinte estrutura: [Ilha, Vizinhas, Pontes], em que Ilha eh uma ilha, 
Vizinhas eh a lista de vizinhas dessa ilha e Pontes eh uma lista de pontes da ilha, inicialmente 
vazia.
*/
estado(Ilhas, Estado) :-
    findall([Ilha, Vizinhas, []], (member(Ilha, Ilhas), vizinhas(Ilhas, Ilha, Vizinhas)), Estado).


% ------------------------------------ 2.5. posicoes_entre/3 -------------------------------------%
/*
O predicado posicoes_entre(Pos1, Pos2, Posicoes) tem como argumentos Pos1, Pos2, ambas sendo 
posicoes, e Posicoes, uma lista ordenada de posicoes entre Pos1 e Pos2, nao inclusive. Se estas nao 
pertencerem a mesma linha ou coluna, devolve false.
*/
% Funcao auxiliar: coloca dois numeros N1 e N2 por ordem ascendente, ou seja, troca-os se N1 > N2. 
% Objetivo: colocar Pos1 e Pos2 sempre por ordem.
maior_numero(N, N, N, N) :- !.
maior_numero(N1, N2, N2, N1) :- N1 > N2, !.
maior_numero(N1, N2, N1, N2) :- N2 > N1, !.

posicoes_entre((L1, C1), (L1, C1), []).
posicoes_entre((L1, C1), (L1, C2), Posicoes) :-
    maior_numero(C1, C2, Col1, Col2),
    findall((L1, C3), (between(Col1, Col2, C3), C3 =\= Col1, C3 =\= Col2), Posicoes).
posicoes_entre((L1, C1), (L2, C1), Posicoes) :-
    maior_numero(L1, L2, Line1, Line2),
    findall((L3, C1), (between(Line1, Line2, L3), L3 =\= Line1, L3 =\= Line2), Posicoes).


% -------------------------------------- 2.6. cria_ponte/3 ---------------------------------------%
/*
O predicado cria_ponte(Pos1, Pos2, Ponte), em que Pos1 e Pos2 sao duas posicoes ordenadas, indica 
que Ponte eh uma estrutura do tipo ponte(Pos1, Pos2), que denota a existencia de uma ponte entre 
essas posicoes.
*/
% Neste predicado, recorre-se novamente a funcao auxiliar maior_numero, definida no predicado 
% anterior, para, novamente, ordenar Pos1 e Pos2.
cria_ponte((L1, C1), (L1, C2), Ponte) :-
    maior_numero(C1, C2, Col1, Col2),
    Ponte = ponte((L1, Col1), (L1, Col2)).
cria_ponte((L1, C1), (L2, C1), Ponte) :-
    maior_numero(L1, L2, Line1, Line2),
    Ponte = ponte((Line1, C1), (Line2, C1)).


% ------------------------------------- 2.7. caminho_livre/3 -------------------------------------%
/*
O predicado caminho_livre(Pos1, Pos2, Posicoes, I, Vz), constituido por duas posicoes Pos1 e Pos2, 
uma lista ordenada de posicoes, Posicoes, uma ilha, I, e uma das vizinhas da ilha I, Vz, devolve 
true se, ao se adicionar uma ponte entre Pos1 e Pos2, I e Vz nao deixam de ser vizinhas. Em caso 
contrario, devolve false.
*/
caminho_livre((L1, C1), (L2, C2),_, ilha(_,(L1, C1)), ilha(_,(L2, C2))) :- !.
caminho_livre((L1, C1), (L2, C2),_, ilha(_,(L2, C2)), ilha(_,(L1,C1))) :- !.

caminho_livre(_, _, Posicoes, ilha(_,(L1,C1)), ilha(_,(L2,C2))) :-
    posicoes_entre((L1,C1), (L2, C2), Posicoes_Entre),
    findall(X, (member(X, Posicoes), member(X, Posicoes_Entre)), Common),
    length(Common, 0).


% ------------------------------ 2.8. actualiza_vizinhas_entrada/5 -------------------------------%
/*
O predicado actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, Entrada, Nova_Entrada) eh constituido 
por duas posicoes entre as quais vai ser adicionada uma ponte, Pos1 e Pos2, uma lista de posicoes, 
Posicoes, uma entrada, Entrada, e tem como ultimo argumento a lista Nova_Entrada, uma lista 
semelhante a lista Entrada, na qual a lista de ilhas vizinhas foi atualizada, sendo removidas as 
ilhas que deixaram de ser vizinhas apos a adicao da ponte.
*/
actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, [ilha(N,(L,C)), Vizinhas, Pontes], Nova_Entrada) :-
    findall(ilha(M,(L1,C1)), (member(ilha(M,(L1,C1)), Vizinhas), caminho_livre(Pos1, Pos2, Posicoes, 
    ilha(N,(L,C)), ilha(M,(L1,C1)))), Result),
    Nova_Entrada = [ilha(N,(L,C)), Result, Pontes].


% ---------------------------- 2.9. actualiza_vizinhas_apos_pontes/4 -----------------------------%
/*
O predicado actualiza_vizinhas_apos_pontes(Estado, Pos1, Pos2, Novo_estado) eh constituido por 
Estado e por duas posicoes Pos1 e Pos2, entre as quais se adicionou uma ponte, significa que o 
resultado de atualizar as ilhas vizinhas de cada entrada apos a adicao da ponte eh a lista 
Novo_estado.
*/
actualiza_vizinhas_apos_pontes([],_,_,[]).
actualiza_vizinhas_apos_pontes([P|R], Pos1, Pos2, [Nova_Entrada|T]) :-
    posicoes_entre(Pos1, Pos2, Posicoes),
    actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, P, Nova_Entrada),
    actualiza_vizinhas_apos_pontes(R, Pos1, Pos2, T).


% ---------------------------------- 2.10. ilhas_terminadas/2 ------------------------------------%
/*
O predicado ilhas_terminadas(Estado, Ilhas_term) eh constituido por um estado, Estado, e indica que 
Ilhas_term eh uma lista constituida por ilhas com todas as pontes associadas, denominadas ilhas 
terminadas. A estrutura de um entrada de Estado eh: [ilha(N_pontes,Pos), Vizinhas, Pontes], e uma 
ilha eh designada como terminada se N_pontes for diferente de 'X', e o comprimento da lista Pontes 
for igual ao inteiro N_pontes.
*/
ilhas_terminadas(Estado, Ilhas_term) :-
    findall(ilha(N,Pos), (member([ilha(N,Pos),_,Pontes],Estado), N \== 'X', length(Pontes, N)), 
    Ilhas_term).


% ---------------------------- 2.11. tira_ilhas_terminadas_entrada/3 -----------------------------%
/*
O predicado tira_ilhas_terminadas_entrada(Ilhas_term, Entrada, Nova_entrada), constituido por uma 
lista de ilhas terminadas, Ilhas_term, e uma entrada, Entrada, indica que o resultado de remover 
todas as ilhas existentes na lista de vizinhas de Entrada que tambem existam na lista Ilhas_term 
se denomina Nova_entrada.
*/
tira_ilhas_terminadas_entrada(Ilhas_term, Entrada, Nova_Entrada) :-
    Entrada = [Ilha, Vz, Pontes],
    subtract(Vz, Ilhas_term, New_Vizinhas),
    Nova_Entrada = [Ilha, New_Vizinhas, Pontes].


% -------------------------------- 2.12. tira_ilhas_terminadas/3 ---------------------------------%
/*
O predicado tira_ilhas_terminadas(Estado, Ilhas_term, Novo_estado), constituido por um estado, 
Estado, e uma lista de ilhas terminadas, Ilhas_term, indica que Novo_estado eh o resultado de 
aplicar o predicado tira_ilhas_terminadas_entrada a cada uma das entradas de Estado.
*/
tira_ilhas_terminadas([],_,[]).
tira_ilhas_terminadas([P|R], Ilhas_term, [H|T]) :-
    tira_ilhas_terminadas_entrada(Ilhas_term, P, H),
    tira_ilhas_terminadas(R, Ilhas_term, T).


% --------------------------- 2.13. marca_ilhas_terminadas_entrada/3 -----------------------------%
/*
O predicado marca_ilhas_terminadas_entrada(Ilhas_term, Entrada, Nova_entrada), no qual Ilhas_term eh 
uma lista de ilhas terminadas e Entrada eh uma entrada, indica que Nova_entrada eh a entrada que 
resulta de substituir o numero de pontes da ilha de Entrada caso esta pertenca a Ilhas_term;
contrariamente, Nova_entrada eh igual a Entrada.
*/
marca_ilhas_terminadas_entrada(Ilhas_term, [ilha(N,Pos),Vz,Pontes], Nova_Entrada) :-
    member(ilha(N,Pos), Ilhas_term), 
    New_Ilha = ilha('X',Pos),
    Nova_Entrada = [New_Ilha,Vz,Pontes].
marca_ilhas_terminadas_entrada(_, [ilha(N,Pos),Vz,Pontes], Nova_Entrada) :-
    New_Ilha = ilha(N,Pos),
    Nova_Entrada = [New_Ilha,Vz,Pontes].


% -------------------------------- 2.14. marca_ilhas_terminadas/3 --------------------------------%
/*
O predicado marca_ilhas_terminadas(Estado, Ilhas_term, Novo_estado), sendo Estado um estado e 
Ilhas_term uma lista de ilhas terminadas, indica que Novo_estado eh o resultado de aplicar o 
predicado marca_ilhas_terminadas_entrada a cada uma das entradas de Estado.
*/
marca_ilhas_terminadas([],_,[]).
marca_ilhas_terminadas([P|R], Ilhas_term, [H|T]) :-
    marca_ilhas_terminadas_entrada(Ilhas_term, P, H),
    marca_ilhas_terminadas(R, Ilhas_term, T).


% ------------------------------- 2.15. trata_ilhas_terminadas/2 ---------------------------------%
/*
O predicado trata_ilhas_terminadas(Estado, Novo_estado), em que Estado eh um estado, indica que 
Novo_estado eh o estado resultante de aplicar os predicados tira_ilhas_terminadas e 
marca_ilhas_terminadas, sequencialmente e por esta ordem, a lista Estado.
*/
trata_ilhas_terminadas(Estado, Novo_Estado) :-
    ilhas_terminadas(Estado, Ilhas_terminadas),
    tira_ilhas_terminadas(Estado, Ilhas_terminadas, Novo_Estado_Aux),
    marca_ilhas_terminadas(Novo_Estado_Aux, Ilhas_terminadas, Novo_Estado).


% ------------------------------------- 2.16. junta_pontes/5 -------------------------------------%
/*
O predicado junta_pontes(Estado, Num_pontes, Ilha1, Ilhas2, Novo_estado) eh constituido por um 
estado (Estado), um inteiro (Num_pontes), duas ilhas (Ilha1 e Ilha2), e indica que Novo_estado eh o 
estado obtido atraves de Estado atraves do seguinte processo: cria-se uma ou mais pontes entre Ilha1 
e Ilha2; adiciona-se a, ou as pontes, as entradas de Estado que correspondem as ilhas entre as quais 
se estabeleceu a ponte; a quantidade de vezes que a ponte e adicionada as respetivas entradas e dada 
pelo inteiro Num_pontes. Apos isto, atualiza-se a lista Estado atraves da aplicacao sequencial dos 
predicados actualiza_vizinhas_apos_pontes e trata_ilhas_terminadas.
*/ 

% Funcao auxiliar: devolve uma lista com n repeticoes de um dado elemento El
repete_el(El, N, L) :-
    length(L, N),
    maplist(=(El), L).

/* Funcao auxiliar: altera nas entradas que comecem por ilha(_,Pos1) e ilha(_,Pos2), a lista 
respetiva de pontes, adicionando-lhe Num_pontes vezes a ponte fornecida como segundo argumento da 
funcao. Indica que Resultado difere de Estado apenas na alteracao dessas duas entradas alteradas.*/
adiciona_pontes(Estado, ponte(Pos1, Pos2), Num_pontes, Resultado) :- 
    member([ilha(N1,Pos1), Vz1, Pontes1], Estado),
    member([ilha(N2,Pos2), Vz2, Pontes2], Estado),
    repete_el(ponte(Pos1, Pos2), Num_pontes, New_pontes),
    append(Pontes1, New_pontes, New_pontes1),
    append(Pontes2, New_pontes, New_pontes2),
    select([ilha(N1,Pos1), Vz1, Pontes1], Estado, [ilha(N1,Pos1), Vz1, New_pontes1], Estado_Aux),
    select([ilha(N2,Pos2), Vz2, Pontes2], Estado_Aux, [ilha(N2,Pos2), Vz2, New_pontes2], Resultado).
    

junta_pontes(Estado, Num_pontes, ilha(_,Pos1), ilha(_,Pos2), Novo_Estado) :-
    cria_ponte(Pos1, Pos2, Ponte),
    adiciona_pontes(Estado, Ponte, Num_pontes, Estado_com_pontes),
    actualiza_vizinhas_apos_pontes(Estado_com_pontes, Pos1, Pos2, Estado_actualizado),
    trata_ilhas_terminadas(Estado_actualizado, Novo_Estado).


                                                                                                                                                      
% --------------------------------------------- FIM ----------------------------------------------%

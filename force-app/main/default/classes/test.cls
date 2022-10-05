public with sharing class test {

    // JAVASCRIPT
    function validarCNPJ(List<Account> selectQuery) {
        
        List<Processos> processosLista = [
            SELECT numProcesso, Cidade
            FROM Processos
        ];

        for(Processos processo : selectQuery){
            processo.numProcesso = 'asdasda';
            processo.Cidade = 'asdsajd';

            processosLista.add(processo);
        }


        update processosLista;
    }
}

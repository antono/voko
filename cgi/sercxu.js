// Farite de Bart Demeyere por ReVo
// GNU-licenco

var UnuajRezultoj='';
var DuajRezultoj='';
var LastajRezultoj='';
var UnuaRezultoDosiero='';
var UnuaRezultoLoko='';
var RE_Sercxata;
var RE_Sercxata_Nur;
var RE_Sercxata_MezaVorto;
var RE_Sercxata_KomencaVorto;
var RE_Sercxata_FinaVorto;
function Inicu(Sercxata)
{
  RE_Sercxata = new RegExp(Sercxata, "i");
  RE_Sercxata_Nur = new RegExp("^"+Sercxata+"$","i");
  RE_Sercxata_MezaVorto = new RegExp(" "+Sercxata+" ","i");
  RE_Sercxata_KomencaVorto = new RegExp("^"+Sercxata+" ","i");
  RE_Sercxata_FinaVorto = new RegExp(" "+Sercxata+"$","i");
}

function Ekzamenu(Eroj, Sercxata, Poz, Eo, KunTraduko, EnEsperanto)
{
  for(j=0;j<Eroj.length;++j)
  {
    var MaksEroj = Eroj[j].length;
    for(i=0;i<MaksEroj - 1;i+=2+Eo)
    {
      var Esprimo = Eroj[j][i + Poz];
      WordPos = Esprimo.search(RE_Sercxata);
      if (WordPos > -1)
      {
        Trovis(Esprimo, Eroj[j], i, Sercxata, Poz, Eo, KunTraduko, EnEsperanto);
      }
    }
  }
}

function Trovis(Esprimo, ErojJ, i, Sercxata, Poz, Eo, KunTraduko, EnEsperanto)
{
  Trovita=Esprimo.match(RE_Sercxata)[0];
  var Rezulto = '';
  if (KunTraduko)
  {
    if (EnEsperanto)
    {
      Rezulto=ErojJ[i + Eo - 1];
    }
    else
      Rezulto=Esprimo.replace(new RegExp(Trovita,"g"),Trovita.bold());
    Rezulto += ": ";
  }
  Rezulto += "<a class='l' href='../art/";
  var Punkto = ErojJ[i + Eo + 1].indexOf('.');
  if (Punkto == -1)
    Rezulto += ErojJ[i + Eo + 1] + ".html";
  else
  {
    Rezulto += ErojJ[i + Eo + 1].substr(0, Punkto) + ".html";
    Rezulto += "#" + ErojJ[i + Eo + 1];
  }
  Rezulto += "' target='precipa'>";
  if (EnEsperanto)
    Rezulto += ErojJ[i + Eo].replace(
      new RegExp(Trovita,"g"),Trovita.bold());
  else
    Rezulto += ErojJ[i + Eo];
  Rezulto += "</a><br>\n";
  if (Esprimo.search(RE_Sercxata_Nur) > -1)
  {
    UnuajRezultoj += Rezulto;
    if (UnuaRezultoDosiero == '')
    { UnuaRezultoLoko = ErojJ[i + Eo + 1];
            if (Punkto == -1)
              UnuaRezultoDosiero = ErojJ[i + Eo + 1];
      else
        UnuaRezultoDosiero = ErojJ[i + Eo + 1].substr(0, Punkto);
    }
  }
  else if (
      RE_Sercxata_MezaVorto.test(Esprimo)
      || RE_Sercxata_KomencaVorto.test(Esprimo)
      || RE_Sercxata_FinaVorto.test(Esprimo))
    DuajRezultoj += Rezulto;
  else
    LastajRezultoj += Rezulto;
}

function Sercxu(Sercxata)
{
  var LokalaUnuaParto = UnuaParto;
  if(Sercxata.length>=1)
  {
    this.status="Laborante, bonvolu atendi...";
    Sercxata = Sercxata.toLowerCase();
    Inicu(Sercxata);
    Ekzamenu(Eroj, Sercxata, 0, 1, true, false);
    var Rezultoj = UnuajRezultoj + DuajRezultoj + LastajRezultoj;
    if(Rezultoj == '')
    { Rezultoj="<CENTER><U>Neniu rezulto trovita!</U></CENTER>\n"; }
    var LokaUnuaRezultoDosiero=UnuaRezultoDosiero;
    var LokaUnuaRezultoLoko=UnuaRezultoLoko;
    this.document.open();
    this.document.write(LokalaUnuaParto+Rezultoj+"</BODY></HTML>");
    this.document.close();
    if (LokaUnuaRezultoDosiero != '')
      open("../art/"+LokaUnuaRezultoDosiero+".html#"
        +LokaUnuaRezultoLoko, "precipa");
    this.status="Finite";
  }
  else
  { this.status="Eraro: Vi devas skribi almenau unu literon!"; }
}

function SercxuEo(Sercxata)
{
  var LokalaUnuaParto = UnuaParto;
  if(Sercxata.length>=1)
  {
    this.status="Laborante, bonvolu atendi...";
    Sercxata = Sercxata.toLowerCase();
    Sercxata = Sercxata.replace(/cx/g, "\u0109")
      .replace(/gx/g, "\u011D").replace(/hx/g, "\u0125")
      .replace(/jx/g, "\u0135").replace(/sx/g, "\u015D")
      .replace(/ux/g, "\u016D");
    Inicu(Sercxata);
    Ekzamenu(Eroj, Sercxata, 1, 1, true, true);
    Ekzamenu(Eo, Sercxata, 0, 0, false, true);
    var Rezultoj = UnuajRezultoj + DuajRezultoj + LastajRezultoj;
    var LokaUnuaRezultoDosiero=UnuaRezultoDosiero;
    var LokaUnuaRezultoLoko=UnuaRezultoLoko;
    if(Rezultoj == '')
    { Rezultoj="<CENTER><U>Neniu rezulto trovita!</U></CENTER>\n"; }
    this.document.open();
    this.document.write(LokalaUnuaParto+Rezultoj+"</BODY></HTML>");
    this.document.close();
    if (LokaUnuaRezultoDosiero != '')
      open("../art/"+LokaUnuaRezultoDosiero+".html#"
        +LokaUnuaRezultoLoko, "precipa");
    this.status="Finite";
  }
  else
  { this.status="Eraro: Vi devas skribi almenau unu literon!"; }
}

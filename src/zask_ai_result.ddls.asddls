@EndUserText.label: 'AI Query Result'
define abstract entity zask_ai_result
{
  @UI.identification: [{ position: 10 }]
  query  : abap.string(0);
//  @UI.identification: [{ position: 20 }]
//  answer : abap.string(0);
}

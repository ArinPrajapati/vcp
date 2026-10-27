(function(){
  var root=document.documentElement; root.classList.add('js');
  var copyBtn=document.getElementById('copy');
  if(copyBtn){copyBtn.addEventListener('click',function(){
    var t=document.getElementById('cmd').textContent.trim();
    var done=function(){copyBtn.textContent='Copied';setTimeout(function(){copyBtn.textContent='Copy'},1600)};
    if(navigator.clipboard){navigator.clipboard.writeText(t).then(done,function(){})}
  })}
  var tabs=[].slice.call(document.querySelectorAll('.tabs button'));
  var panes=[].slice.call(document.querySelectorAll('.pane'));
  if(!tabs.length)return;
  var touched=false;
  function show(i){tabs.forEach(function(b,k){b.setAttribute('aria-selected',k===i)});panes.forEach(function(p,k){p.classList.toggle('on',k===i)})}
  tabs.forEach(function(b,i){b.addEventListener('click',function(){touched=true;show(i)})});
  show(0);
  if(!window.matchMedia('(prefers-reduced-motion: reduce)').matches){
    setTimeout(function(){if(!touched)show(1)},2600);
    setTimeout(function(){if(!touched)show(0)},5600);
  }
})();

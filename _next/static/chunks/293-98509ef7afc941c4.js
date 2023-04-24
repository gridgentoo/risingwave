"use strict";(self.webpackChunk_N_E=self.webpackChunk_N_E||[]).push([[293],{14293:function(r,t,n){n.d(t,{_P:function(){return v},bK:function(){return f},o:function(){return d},rE:function(){return y}});var e=n(41799),a=n(99534),o=n(828),i=n(96486);function l(r){return{node:r,temp:!1,perm:!1,isInput:!0,isOutput:!0,g:0}}function u(r){var t=new Map,n=!0,e=!1,a=void 0;try{for(var o,i=r[Symbol.iterator]();!(n=(o=i.next()).done);n=!0){var u=o.value;t.set(u.id,u)}}catch(T){e=!0,a=T}finally{try{n||null==i.return||i.return()}finally{if(e)throw a}}var f=new Map,y=new Map,v=function(r){var n=y.get(r);if(void 0!==n)return n;var e={nextNodes:new Array},a=t.get(r);if(void 0===a)throw Error("no such id ".concat(r));var o=!0,i=!1,l=void 0;try{for(var u,d=a.parentIds[Symbol.iterator]();!(o=(u=d.next()).done);o=!0){var c=u.value;v(c).nextNodes.push(e)}}catch(T){i=!0,l=T}finally{try{o||null==d.return||d.return()}finally{if(i)throw l}}return y.set(r,e),f.set(e,r),e},d=!0,c=!1,h=void 0;try{for(var s,w=r[Symbol.iterator]();!(d=(s=w.next()).done);d=!0){var p=s.value;v(p.id)}}catch(T){c=!0,h=T}finally{try{d||null==w.return||w.return()}finally{if(c)throw h}}var x=new Map,g=new Array,m=!0,b=!1,S=void 0;try{for(var M,E=f.keys()[Symbol.iterator]();!(m=(M=E.next()).done);m=!0){var I=M.value;g.push(I)}}catch(T){b=!0,S=T}finally{try{m||null==E.return||E.return()}finally{if(b)throw S}}var N=function(r){var t=[],n=[],e=new Map,a=function(r){if(r.temp)throw Error("This is not a DAG");if(!r.perm){r.temp=!0;var n=-1,o=!0,i=!1,l=void 0;try{for(var u,f=r.node.nextNodes[Symbol.iterator]();!(o=(u=f.next()).done);o=!0){var y=u.value;e.get(y).isInput=!1,r.isOutput=!1;var v=a(e.get(y));v>n&&(n=v)}}catch(T){i=!0,l=T}finally{try{o||null==f.return||f.return()}finally{if(i)throw l}}r.temp=!1,r.perm=!0,r.g=n+1,t.unshift(r.node)}return r.g},o=!0,i=!1,u=void 0;try{for(var f,y=r[Symbol.iterator]();!(o=(f=y.next()).done);o=!0){var v=f.value,d=l(v);e.set(v,d),n.push(d)}}catch(T){i=!0,u=T}finally{try{o||null==y.return||y.return()}finally{if(i)throw u}}var c=0,h=!0,s=!1,w=void 0;try{for(var p,x=n[Symbol.iterator]();!(h=(p=x.next()).done);h=!0){var g=p.value,m=a(g);m>c&&(c=m)}}catch(T){s=!0,w=T}finally{try{h||null==x.return||x.return()}finally{if(s)throw w}}var b=!0,S=!1,M=void 0;try{for(var E,I=n[Symbol.iterator]();!(b=(E=I.next()).done);b=!0){var N=E.value;N.g=c-N.g}}catch(T){S=!0,M=T}finally{try{b||null==I.return||I.return()}finally{if(S)throw M}}for(var k=new Array,A=0;A<c+1;++A)k.push({nodes:[],occupyRow:new Set});var _=new Map,R=new Map,Z=!0,B=!1,C=void 0;try{for(var O,D=n[Symbol.iterator]();!(Z=(O=D.next()).done);Z=!0){var G=O.value;k[G.g].nodes.push(G.node),_.set(G.node,G.g)}}catch(T){B=!0,C=T}finally{try{Z||null==D.return||D.return()}finally{if(B)throw C}}var K=function(r,t){R.set(r,t),k[_.get(r)].occupyRow.add(t)},P=function(r,t,n){for(var e=r;e<=t;++e)k[e].occupyRow.add(n)},j=function(r,t){return k[r].occupyRow.has(t)},q=function(r,t,n){if(n<0)return!1;for(var e=r;e<=t;++e)if(j(e,n))return!0;return!1},z=!0,F=!1,H=void 0;try{for(var J,L=r[Symbol.iterator]();!(z=(J=L.next()).done);z=!0)J.value.nextNodes.sort((function(r,t){return _.get(t)-_.get(r)}))}catch(T){F=!0,H=T}finally{try{z||null==L.return||L.return()}finally{if(F)throw H}}var Q=!0,U=!1,V=void 0;try{for(var W,X=k[Symbol.iterator]();!(Q=(W=X.next()).done);Q=!0){var Y=W.value,$=!0,rr=!1,tr=void 0;try{for(var nr,er=Y.nodes[Symbol.iterator]();!($=(nr=er.next()).done);$=!0){var ar=nr.value;if(!R.has(ar)){var or=!0,ir=!1,lr=void 0;try{for(var ur,fr=ar.nextNodes[Symbol.iterator]();!(or=(ur=fr.next()).done);or=!0){var yr=ur.value;if(!R.has(yr)){for(var vr=-1;q(_.get(ar),_.get(yr),++vr););K(ar,vr),K(yr,vr),P(_.get(ar)+1,_.get(yr)-1,vr);break}}}catch(T){ir=!0,lr=T}finally{try{or||null==fr.return||fr.return()}finally{if(ir)throw lr}}if(!R.has(ar)){for(var dr=-1;j(_.get(ar),++dr););K(ar,dr)}}var cr=!0,hr=!1,sr=void 0;try{for(var wr,pr=ar.nextNodes[Symbol.iterator]();!(cr=(wr=pr.next()).done);cr=!0){var xr=wr.value;if(!R.has(xr)){var gr=R.get(ar);if(q(_.get(ar)+1,_.get(xr),gr)){for(gr=-1;q(_.get(ar)+1,_.get(xr),++gr););K(xr,gr),P(_.get(ar)+1,_.get(xr)-1,gr)}else K(xr,gr),P(_.get(ar)+1,_.get(xr)-1,gr)}}}catch(T){hr=!0,sr=T}finally{try{cr||null==pr.return||pr.return()}finally{if(hr)throw sr}}}}catch(T){rr=!0,tr=T}finally{try{$||null==er.return||er.return()}finally{if(rr)throw tr}}}}catch(T){U=!0,V=T}finally{try{Q||null==X.return||X.return()}finally{if(U)throw V}}var mr=new Map,br=!0,Sr=!1,Mr=void 0;try{for(var Er,Ir=r[Symbol.iterator]();!(br=(Er=Ir.next()).done);br=!0){var Nr=Er.value;mr.set(Nr,[_.get(Nr),R.get(Nr)])}}catch(T){Sr=!0,Mr=T}finally{try{br||null==Ir.return||Ir.return()}finally{if(Sr)throw Mr}}return mr}(g),k=!0,A=!1,_=void 0;try{for(var R,Z=N[Symbol.iterator]();!(k=(R=Z.next()).done);k=!0){var B=R.value,C=f.get(B[0]);if(!C)throw Error("no corresponding actorboxid of node ".concat(B[0]));var O=t.get(C);if(!O)throw Error("actorbox id ".concat(C," is not present in actorBoxIdToActorBox"));x.set(O,B[1])}}catch(T){A=!0,_=T}finally{try{k||null==Z.return||Z.return()}finally{if(A)throw _}}return x}function f(r,t,n){var e=u(r),a=new Map,l=new Map,f=0,y=0,v=!0,d=!1,c=void 0;try{for(var h,s=e[Symbol.iterator]();!(v=(h=s.next()).done);v=!0){var w=h.value,p=w[0],x=w[1][0],g=w[1][1],m=a.get(x)||0;p.width>m&&a.set(x,p.width);var b=l.get(g)||0;p.height>b&&l.set(g,p.height),f=(0,i.max)([x,f])||0,y=(0,i.max)([g,y])||0}}catch(j){d=!0,c=j}finally{try{v||null==s.return||s.return()}finally{if(d)throw c}}for(var S=new Map,M=new Map,E=function(r,t,n,e){var a=n.get(r);if(a)return a;if(0===r)a=0;else{var o=e.get(r-1);if(!o)throw Error("".concat(r-1," has no result"));a=E(r-1,t,n,e)+o+t}return n.set(r,a),a},I=0;I<=f;++I)E(I,t,S,a);for(var N=0;N<=y;++N)E(N,n,M,l);var k=[],A=!0,_=!1,R=void 0;try{for(var Z,B=e[Symbol.iterator]();!(A=(Z=B.next()).done);A=!0){var C=(0,o.Z)(Z.value,2),O=C[0],T=(0,o.Z)(C[1],2),D=T[0],G=T[1],K=S.get(D),P=M.get(G);if(void 0===K||void 0===P)throw Error("x of layer ".concat(D,": ").concat(K,", y of row ").concat(G,": ").concat(P," "));k.push({id:O.id,x:K,y:P,data:O})}}catch(j){_=!0,R=j}finally{try{A||null==B.return||B.return()}finally{if(_)throw R}}return k}function y(r,t,n,o){var i=function(r,t,n,o){var i=[],l=!0,u=!1,y=void 0;try{for(var v,d=r[Symbol.iterator]();!(l=(v=d.next()).done);l=!0){var c=v.value,h=c.id,s=c.name,w=c.order,p=c.parentIds,x=(0,a.Z)(c,["id","name","order","parentIds"]);i.push((0,e.Z)({id:h,name:s,parentIds:p,width:2*o,height:2*o,order:w},x))}}catch(g){u=!0,y=g}finally{try{l||null==d.return||d.return()}finally{if(u)throw y}}return f(i,t,n).map((function(r){var t=r.id,n=r.x,e=r.y;return{id:t,data:r.data,x:n+o,y:e+o}}))}(r,n,t,o);return i.map((function(r){var t=r.id,n=r.x,e=r.y;return{id:t,data:r.data,x:e,y:n}}))}function v(r){var t=[],n=new Map,e=!0,a=!1,o=void 0;try{for(var i,l=r[Symbol.iterator]();!(e=(i=l.next()).done);e=!0){var u=i.value;n.set(u.id,u)}}catch(S){a=!0,o=S}finally{try{e||null==l.return||l.return()}finally{if(a)throw o}}var f=!0,y=!1,v=void 0;try{for(var d,c=r[Symbol.iterator]();!(f=(d=c.next()).done);f=!0){var h=d.value,s=!0,w=!1,p=void 0;try{for(var x,g=h.data.parentIds[Symbol.iterator]();!(s=(x=g.next()).done);s=!0){var m=x.value,b=n.get(m);t.push({points:[{x:h.x,y:h.y},{x:b.x,y:b.y}],source:h.id,target:m})}}catch(S){w=!0,p=S}finally{try{s||null==g.return||g.return()}finally{if(w)throw p}}}}catch(S){y=!0,v=S}finally{try{f||null==c.return||c.return()}finally{if(y)throw v}}return t}function d(r){var t=[],n=new Map,e=!0,a=!1,o=void 0;try{for(var i,l=r[Symbol.iterator]();!(e=(i=l.next()).done);e=!0){var u=i.value;n.set(u.id,u)}}catch(S){a=!0,o=S}finally{try{e||null==l.return||l.return()}finally{if(a)throw o}}var f=!0,y=!1,v=void 0;try{for(var d,c=r[Symbol.iterator]();!(f=(d=c.next()).done);f=!0){var h=d.value,s=!0,w=!1,p=void 0;try{for(var x,g=h.data.parentIds[Symbol.iterator]();!(s=(x=g.next()).done);s=!0){var m=x.value,b=n.get(m);t.push({points:[{x:h.x+h.data.width/2,y:h.y+h.data.height/2},{x:b.x+b.data.width/2,y:b.y+b.data.height/2}],source:h.id,target:m})}}catch(S){w=!0,p=S}finally{try{s||null==g.return||g.return()}finally{if(w)throw p}}}}catch(S){y=!0,v=S}finally{try{f||null==c.return||c.return()}finally{if(y)throw v}}return t}}}]);
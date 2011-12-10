function openPopup (href) {
  if(href.search(/\?/) == -1)
    href += '?popup=1';
  else
    href += '&popup=1';
  popup = window.open(href, "_popup", "width=500,height=400,dependent=yes,location=no,menubar=no,toolbar=no,scrollbars=yes");
  popup.focus();
}

function closeAfter(timeout) {
  window.setTimeout('window.close()', timeout)
}

var MyUtils = {
  replaceSurroundedImage: function(root, new_src, width, height) {
    if(root.childNodes) {
      for(var i = 0; i < root.childNodes.length; i++) {
        node = root.childNodes[i]
        if(node.nodeType == 1 && node.nodeName == 'IMG') {
          node.src = new_src
          if(width != null)
            node.style.width = width
          if(height != null)
            node.style.height = height
          return true;
        }
      }
    } else return false;
  },
  placeAt: function(element, x, y) {
    element.makePositioned();
    element.setStyle({
      position: 'absolute',
      left: x + 'px',
      top:  y + 'px'
    });
  }
}
Element.addMethods(MyUtils);

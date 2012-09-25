var InplaceTagEditor = Class.create({
  initialize: function(root, options) {
    this.initializeWithOptions(root, options);
    this.setUpEditEventHandlers();
  },
  
  initializeWithOptions: function(root, options) {
    options = InplaceTagEditor.defaultOptions.merge(options || {});
    this.root = $(root);
    this.getText = options.get('getText').bind(this.root);
    this.updateContent = options.get('updateContent').bind(this.root);
    this.originalContent = null;
    this.form = null;
  },
  
  setUpEditEventHandlers: function() {
    this.root.stopObserving('keyup');
    this.root.on('click', this.showForm.bindAsEventListener(this));
  },
  
  setUpShowEventHandlers: function() {
    this.root.stopObserving('click');
    this.root.on('keyup', this.handleKeyUp.bindAsEventListener(this));
    this.form.on('submit', function() { return false; });
  },
  
  showForm: function() {
    this.originalContent = this.root.innerHTML;
    this.constructForm();
    this.root.update(this.form);
    this.root.addClassName('edit');
    this.setUpShowEventHandlers();
    this.form.focusFirstElement();
  },
  
  hideForm: function(content) {
    this.root.update(this.originalContent.stripScripts());
    if(content)
      this.updateContent(content);
    this.setUpEditEventHandlers();
  },
  
  submitForm: function() {
    alert('submit');
    
    return false;
  },
  
  handleKeyUp: function(event) {
    event = event || window.event;
    switch(event.keyCode) {
      case Event.KEY_RETURN:
        this.submitForm();
        break;
      case Event.KEY_ESC:
        this.hideForm();
        break;
    }
    Event.stop(event);
  },
  
  constructForm: function() {
      this.form = new Element('form');
      var input = new Element('input', {type: 'text', value: this.getText()});
      input.on('blur', this.submitForm.bindAsEventListener(this));
      
      this.form.update(input);
  }
});

InplaceTagEditor.defaultOptions = $H({
  getText: function() { return this.innerHTML; },
  updateContent: function(content) { this.innerHTML = content; }
});

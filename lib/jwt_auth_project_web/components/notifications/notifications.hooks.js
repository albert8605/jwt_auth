let AutoDismissNotification = {
  mounted() {
    setTimeout(() => {
      const id = this.el.getAttribute("data-id");
      this.pushEvent("dismiss_notification", { id });
    }, 3000);
  }
};

export { AutoDismissNotification }; 
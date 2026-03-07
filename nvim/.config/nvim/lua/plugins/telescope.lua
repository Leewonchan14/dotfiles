return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        find_files = {
          hidden = true, -- . 으로 시작하는 숨김 파일 검색 결과에 포함
        },
      },
    },
  },
}

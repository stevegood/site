<#include "header.ftl">

	<#include "menu.ftl">

	<div class="well page">
		<div class="page-header">
			<h1><#escape x as x?xml>${content.title}</#escape></h1>
		</div>

		<p><em>${content.date?string("MMMM dd, yyyy")}</em></p>

		<p>${content.body}</p>

		<hr />
	</div>

<#include "footer.ftl">